defmodule MasterProgrammieraufgabeWeb.TriangleLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView
  alias MasterProgrammieraufgabe.CircleDrawer
  alias Phoenix.LiveView.JS
  alias MasterProgrammieraufgabe.MathUtils

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-semibold text-2xl w-full flex justify-center p-4">Programmieraufgabe</h1>
    <div class="mx-auto">
      <div>
        <button phx-click="button-click" ><%= if @helpers_hidden == true do %> Show Helpers <%= else %> Hide Helpers <%=end%> </button>
      </div>
      <div>
        <p>Durchmesser d (mal Wurzel 3): <%= if @diameter_coords != nil, do: @diameter_coords.diameter %> <br> Seitenlänge: <%= if @triangle != [], do: @triangle.distance %> </p>
      </div>
      <div class="border-2 m-4 border-black">
      <svg
        id="circle-drawer"
        phx-hook="CircleDrawer"
        viewBox="0 0 100 100"
        xmlns="http://www.w3.org/2000/svg"
      >
        <%= for %{x: x, y: y, r: r, color: color} <- @canvas.circles do %>
          <circle cx={x} cy={y} r={r} fill={color} />
        <% end %>
        <%= if @diameter_coords != nil and @helpers_hidden == false do%>
          <line x1={"#{@diameter_coords.x1}"} y1={"#{@diameter_coords.y1}"} x2={"#{@diameter_coords.x2}"} y2={"#{@diameter_coords.y2}"} stroke="black" stroke-width="0.25" stroke-dasharray="1, 0.5"/>
        <% end %>
         <%= if @helper_lines != nil and @helpers_hidden == false do%>
              <line :for={%{x1: x1, y1: y1, x2: x2, y2: y2,color: color} <- @canvas.lines} x1={x1} y1={y1} x2={x2} y2={y2} stroke={color} stroke-width="0.25" />
        <% end %>
        <%= if @triangle != [] do%>
              <polygon points={"#{@triangle.x1},#{@triangle.y1}
                                #{@triangle.x2},#{@triangle.y2}
                                #{@triangle.x3},#{@triangle.y3}"}
                                fill="#0002" stroke="black" stroke-width="0.25" />
        <% end %>
      </svg>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(:canvas, CircleDrawer.new_canvas())
    |> assign(:diameter_coords,nil)
    |> assign(:helper_lines, nil)
    |> assign(:triangle, [])
    |> assign(:helpers_hidden, true)
    |> ok()
  end


  @impl true
  def handle_event("canvas-click", %{"x" => x, "y" => y}, socket) do
    canvas = socket.assigns.canvas
    x = to_number(x)
    y = to_number(y)

    circle = CircleDrawer.new_circle(x, y)
    updated_canvas = CircleDrawer.add_circle(canvas, circle)

    pointset = updated_canvas.circles |> extract_coordinates()
    updated_diameter_coords = MathUtils.find_diameter(pointset)
    updated_canvas = CircleDrawer.reset_circle(updated_canvas) |> CircleDrawer.reset_line()


    {hull_points, helper_lines, triangle_coords} =
      if length(pointset) >= 3 do
        hull_points = MathUtils.graham_scan(pointset)
        [helper_lines,triangle_coords] = MathUtils.get_helper_lines(updated_diameter_coords, hull_points)
        colors = ["green","green","blue","blue","orange","orange"]
        %{lines: helper_lines} = Enum.reduce(helper_lines, %{colors: colors,lines: []}, fn (%{x1: x1,y1: y1,x2: x2,y2: y2},%{colors: [color|colors],lines: lines}) -> %{lines: [CircleDrawer.new_line(x1,y1,x2,y2,color)|lines], colors: colors} end)
        hull_points =  Enum.map(hull_points, fn {x,y} -> CircleDrawer.new_circle(x,y,"red") end)
        {hull_points, helper_lines,triangle_coords}
      else
        {[],[],[]}
      end

    updated_canvas = Enum.reduce(helper_lines,updated_canvas,fn line, uc -> CircleDrawer.add_line(uc,line) end)
    updated_canvas = Enum.reduce(hull_points,updated_canvas,fn circle, uc -> CircleDrawer.update_circle(uc,circle) end)

    socket
    |> assign(:canvas, updated_canvas)
    |> assign(:diameter_coords, updated_diameter_coords)
    |> assign(:helper_lines, helper_lines)
    |> assign(:triangle, triangle_coords)
    |> noreply()
  end

  def handle_event("button-click",_, socket) do
    if socket.assigns.helpers_hidden == true do
      socket
      |> assign(:helpers_hidden, false)
      |> noreply()
    else
      socket
      |> assign(:helpers_hidden, true)
      |> noreply()
    end
  end
  def extract_coordinates(circles) do
    Enum.map(circles, &{&1.x, &1.y})
  end


  @impl true
  defp to_number(number) when is_binary(number), do: Float.parse(number) |> elem(0)
  defp to_number(number), do: number

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}
end
