defmodule MasterProgrammieraufgabeWeb.TriangleLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView
  alias MasterProgrammieraufgabe.CircleDrawer.Circle
  alias MasterProgrammieraufgabe.CircleDrawer
  alias Phoenix.LiveView.JS
  alias MasterProgrammieraufgabe.MathUtils

  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-semibold">CircleDraw</h1>
    <div class="mx-auto">
      <svg
        id="circle-drawer"
        phx-hook="CircleDrawer"
        viewBox="0 0 100 100"
        xmlns="http://www.w3.org/2000/svg"
      >
        <%= for %{x: x, y: y, r: r, color: color} <- @canvas.circles do %>
          <circle cx={x} cy={y} r={r} fill={color} />
        <% end %>
        <%= if @diameter_coords != nil do%>
          <line x1={"#{@diameter_coords.x1}"} y1={"#{@diameter_coords.y1}"} x2={"#{@diameter_coords.x2}"} y2={"#{@diameter_coords.y2}"} stroke="black" stroke-width="0.25" stroke-dasharray="1, 0.5"/>
        <% end %>
         <%= if @helper_lines != nil do%>
              <line :for={%{x1: x1, y1: y1, x2: x2, y2: y2} <- @canvas.lines} x1={x1} y1={y1} x2={x2} y2={y2} stroke="black" stroke-width="0.25" />
        <% end %>
      </svg>
    </div>
    """
  end

  defp prettify_coordinates(float) when is_float(float), do: Float.floor(float)
  defp prettify_coordinates(int) when is_integer(int), do: int

  @impl true
  def mount(_, _, socket) do
    socket
    |> assign(:canvas, CircleDrawer.new_canvas())
    |> assign(:diameter_coords,nil)
    |> assign(:helper_lines, nil)
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
    updated_canvas = CircleDrawer.reset_circle(updated_canvas)
    updated_canvas = CircleDrawer.reset_line(updated_canvas)


    {hull_points, helper_lines} =
      if length(pointset) >= 3 do
        hull_points = MathUtils.graham_scan(pointset)
        helper_lines = MathUtils.get_helper_lines(updated_diameter_coords, hull_points) |> Enum.map(fn %{x1: x1,y1: y1,x2: x2,y2: y2} -> CircleDrawer.new_line(x1,y1,x2,y2) end)
        hull_points =  Enum.map(hull_points, fn {x,y} -> CircleDrawer.new_circle(x,y,"red") end)
        dbg({hull_points, helper_lines})
        {hull_points, helper_lines}
      else
        {[],[]}
      end



    updated_canvas = Enum.reduce(helper_lines,updated_canvas,fn line, uc -> CircleDrawer.add_line(uc,line) end)
    dbg(updated_canvas)
    updated_canvas = Enum.reduce(hull_points,updated_canvas,fn circle, uc -> CircleDrawer.update_circle(uc,circle) end)


    socket
    |> assign(:canvas, updated_canvas)
    |> assign(:diameter_coords, updated_diameter_coords)
    |> assign(:helper_lines, helper_lines)

    |> noreply()
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