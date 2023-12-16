defmodule MasterProgrammieraufgabe.CircleDrawer do
  defmodule Circle do
    @beginning_radius 0.3
    @beginning_color "black"
    @enforce_keys [:x, :y]
    defstruct x: nil, y: nil, r: @beginning_radius, color: @beginning_color
    @type t :: %__MODULE__{}
  end

  defmodule Canvas do
    defstruct circles: [], selected: nil
    @type t :: %__MODULE__{circles: [Circle.t()], selected: Circle.t()}
  end

  def new_canvas, do: %Canvas{}

  def new_circle(x, y, color \\ "black"), do: %Circle{x: x, y: y, color: color}

  def update_circle(canvas, %{x: x, y: y} = circle) do
    index =
      Enum.find_index(canvas.circles, fn
        %{x: ^x, y: ^y} -> true
        _ -> false
      end)

    updated_circles = List.replace_at(canvas.circles, index, circle)

    %{canvas | circles: updated_circles}
  end

  def reset_circle(canvas) do
     %{canvas| circles: Enum.map(canvas.circles, fn %{x: x,y: y} -> new_circle(x,y,"black") end)}

  end

  def add_circle(canvas, circle) do
    %{canvas | circles: [circle | canvas.circles]}
  end

end
