defmodule MasterProgrammieraufgabeWeb.TriangleLive do
  # In Phoenix v1.6+ apps, the line is typically: use MyAppWeb, :live_view
  use Phoenix.LiveView
  alias MasterProgrammieraufgabe.CanvasDrawer
  alias Phoenix.LiveView.JS
  alias MasterProgrammieraufgabe.MathUtils

  @impl true
  def render(assigns) do
    # Die Funktion übernimmt das rendern der HTML Seite sie empfängt die assigns die in mount() gesetzt wurden
    ~H"""
    <div class="text-white  bg-main-dark m-auto max-w-[80%] rounded-xl shadow-sm shadow-black overflow-hidden">
      <div class="bg-main-darker py-6">
        <h1 class="font-bold font-geist text-2xl w-full flex justify-center ">Programmieraufgabe Niklas Grotzeck</h1>
        <p class=" text-main-accent w-full flex justify-center pt-2"> Masterbewerbung Digital Reality - Sommersemester 2024</p>
      </div>
      <div class="px-4 pb-4">
        <div class="my-4">
          <p>Durchmesser d⋅√3: <%= if @diameter_coords != nil, do: @diameter_coords.diameter %> <br> Seitenlänge: <%= if @triangle != [], do: @triangle.distance %> </p>
        </div>
        <div class="border-2 border-black rounded-lg overflow-hidden relative">
          <svg
            id="circle-drawer"
            phx-hook="CircleDrawer"
            viewBox="0 0 100 50"
            xmlns="http://www.w3.org/2000/svg"
            class="bg-white"
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
          <button phx-click="helper-button-click" class="select-none shadow-sm shadow-black bg-main-dark rounded-full  w-40 px-4 py-2 absolute bottom-2 right-2 hover:bg-main-highlight"><%= if @helpers_hidden == true do %> Show Helpers <% else %> Hide Helpers <%end%> </button>
          <button phx-click="reset-button-click" class="select-none shadow-sm shadow-black bg-main-dark rounded-full   px-4 py-2 absolute bottom-2 left-2 hover:bg-main-highlight">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" data-slot="icon" class="w-5 h-5">
                <path fill-rule="evenodd" d="M7.793 2.232a.75.75 0 0 1-.025 1.06L3.622 7.25h10.003a5.375 5.375 0 0 1 0 10.75H10.75a.75.75 0 0 1 0-1.5h2.875a3.875 3.875 0 0 0 0-7.75H3.622l4.146 3.957a.75.75 0 0 1-1.036 1.085l-5.5-5.25a.75.75 0 0 1 0-1.085l5.5-5.25a.75.75 0 0 1 1.06.025Z" clip-rule="evenodd" />
            </svg>
          </button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_, _, socket) do
    # hier werden initial die assigns beim aufrufen der Seite gesetzt
    socket
    |> assign(:canvas, CanvasDrawer.new_canvas())
    |> assign(:diameter_coords,nil)
    |> assign(:helper_lines, nil)
    |> assign(:triangle, [])
    |> assign(:helpers_hidden, true)
    |> ok()
  end


  @impl true
  def handle_event("canvas-click", %{"x" => x, "y" => y}, socket) do
    # Die Funktion wird aufgerufen wenn auf den Canvas geklickt wird sie erhält ihre Daten aus app.js, in der ein EventListener auf den Canvas gesetzt wurde
    canvas = socket.assigns.canvas
    x = to_number(x)
    y = to_number(y)

    # erzeugt einen neuen Kreis an der Klick-Poition und fügt ihn dem Canvas hinzu
    circle = CanvasDrawer.new_circle(x, y)
    updated_canvas = CanvasDrawer.add_circle(canvas, circle)

    # extrahiert alle Koordinaten aus dem Canvas
    pointset = updated_canvas.circles |> extract_coordinates()

    # ermittelt die Koordinaten des neuen Durchmesser
    updated_diameter_coords = MathUtils.find_diameter(pointset)
    # löscht alle Linien und Kreise aus dem Canvas
    updated_canvas = CanvasDrawer.reset_circle(updated_canvas) |> CanvasDrawer.reset_line()

    # ermittelt die Koordinaten der Hilfslinien und des Dreiecks und die Punkte der konvexen Hülle
    {hull_points, helper_lines, triangle_coords} =
      if length(pointset) >= 3 do
        hull_points = MathUtils.graham_scan(pointset)
        [helper_lines,triangle_coords] = MathUtils.get_helper_lines(updated_diameter_coords, hull_points)
        colors = ["green","green","blue","blue","orange","orange"]
        %{lines: helper_lines} = Enum.reduce(helper_lines, %{colors: colors,lines: []}, fn (%{x1: x1,y1: y1,x2: x2,y2: y2},%{colors: [color|colors],lines: lines}) -> %{lines: [CanvasDrawer.new_line(x1,y1,x2,y2,color)|lines], colors: colors} end)
        hull_points =  Enum.map(hull_points, fn {x,y} -> CanvasDrawer.new_circle(x,y,"red") end)
        {hull_points, helper_lines,triangle_coords}
      else
        {[],[],[]}
      end

      # fügt die Linien und Kreise dem Canvas hinzu
    updated_canvas = Enum.reduce(helper_lines,updated_canvas,fn line, uc -> CanvasDrawer.add_line(uc,line) end)
    updated_canvas = Enum.reduce(hull_points,updated_canvas,fn circle, uc -> CanvasDrawer.update_circle(uc,circle) end)

    # assigns werden gesetzt
    socket
    |> assign(:canvas, updated_canvas)
    |> assign(:diameter_coords, updated_diameter_coords)
    |> assign(:helper_lines, helper_lines)
    |> assign(:triangle, triangle_coords)
    |> noreply()
  end

  def handle_event("helper-button-click",_, socket) do
    # Funktion wird aufgerufen wenn der Helper-Button geklickt wird und zeigt oder versteckt die Hilfslinien
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

  def handle_event("reset-button-click", _, socket) do
    # Funktion wird aufgerufen wenn der Reset-Button geklickt wird und setzt den Canvas zurück
    socket
    |> assign(:canvas, CanvasDrawer.new_canvas())
    |> assign(:diameter_coords,nil)
    |> assign(:triangle,[] )
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
