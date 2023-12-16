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
          <line x1={"#{Enum.at(@diameter_coords,0)}"} y1={"#{Enum.at(@diameter_coords,1)}"} x2={"#{Enum.at(@diameter_coords,2)}"} y2={"#{Enum.at(@diameter_coords,3)}"} stroke="black" stroke-width="0.25" stroke-dasharray="1, 0.5"/>
        <% end %>
        <%= if @helper_line1 != [] do%>
          <line x1={"#{Enum.at(@helper_line1,0)}"} y1={"#{Enum.at(@helper_line1,1)}"} x2={"#{Enum.at(@helper_line1,2)}"} y2={"#{Enum.at(@helper_line1,3)}"} stroke="black" stroke-width="0.25"/>
        <% end %>
        <%= if @helper_line2 != [] do%>
          <line x1={"#{Enum.at(@helper_line2,0)}"} y1={"#{Enum.at(@helper_line2,1)}"} x2={"#{Enum.at(@helper_line2,2)}"} y2={"#{Enum.at(@helper_line2,3)}"} stroke="black" stroke-width="0.25"/>
        <% end %>
        <%= if @helper_line3 != [] do%>
          <line x1={"#{Enum.at(@helper_line3,0)}"} y1={"#{Enum.at(@helper_line3,1)}"} x2={"#{Enum.at(@helper_line3,2)}"} y2={"#{Enum.at(@helper_line3,3)}"} stroke="blue" stroke-width="0.25"/>
        <% end %>
        <%= if @helper_line4 != [] do%>
          <line x1={"#{Enum.at(@helper_line4,0)}"} y1={"#{Enum.at(@helper_line4,1)}"} x2={"#{Enum.at(@helper_line4,2)}"} y2={"#{Enum.at(@helper_line4,3)}"} stroke="blue" stroke-width="0.25"/>
        <% end %>
        <%= if @helper_line5 != [] do%>
          <line x1={"#{Enum.at(@helper_line5,0)}"} y1={"#{Enum.at(@helper_line5,1)}"} x2={"#{Enum.at(@helper_line5,2)}"} y2={"#{Enum.at(@helper_line5,3)}"} stroke="green" stroke-width="0.25"/>
        <% end %>
        <%= if @helper_line6 != [] do%>
          <line x1={"#{Enum.at(@helper_line6,0)}"} y1={"#{Enum.at(@helper_line6,1)}"} x2={"#{Enum.at(@helper_line6,2)}"} y2={"#{Enum.at(@helper_line6,3)}"} stroke="green" stroke-width="0.25"/>
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
    |> assign(:helper_line1, [])
    |> assign(:helper_line2, [])
    |> assign(:helper_line3, [])
    |> assign(:helper_line4, [])
    |> assign(:helper_line5, [])
    |> assign(:helper_line6, [])
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


    {hull_points, cross_points} =
      if length(pointset) >= 3 do
        hull_points = MathUtils.graham_scan(pointset)
        cross_points = MathUtils.get_helper_lines(updated_diameter_coords, hull_points)
        hull_points =  Enum.map(hull_points, fn {x,y} -> CircleDrawer.new_circle(x,y,"red") end)
        {hull_points, cross_points}
      else
        {[],{[],[],[],[],[],[]}}
      end

      {cross_points1, cross_points2, cross_points3,cross_points4, cross_points5, cross_points6} = cross_points


    updated_canvas = Enum.reduce(hull_points,updated_canvas,fn circle, uc -> CircleDrawer.update_circle(uc,circle) end)

    socket
    |> assign(:canvas, updated_canvas)
    |> assign(:diameter_coords, updated_diameter_coords)
    |> assign(:helper_line1, cross_points1)
    |> assign(:helper_line2, cross_points2)
    |> assign(:helper_line3, cross_points3)
    |> assign(:helper_line4, cross_points4)
    |> assign(:helper_line5, cross_points5)
    |> assign(:helper_line6, cross_points6)
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
