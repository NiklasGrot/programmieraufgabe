defmodule MasterProgrammieraufgabe.CircleDrawer do
  defmodule Circle do
    @beginning_radius 0.3
    @beginning_color "black"
    @enforce_keys [:x, :y]
    defstruct x: nil, y: nil, r: @beginning_radius, color: @beginning_color
    @type t :: %__MODULE__{}
  end

  defmodule StraightLine do
    @enforce_keys [:x1, :y1, :x2, :y2]
    defstruct x1: nil, y1: nil, x2: nil, y2: nil
    @type t :: %__MODULE__{}
  end

  defmodule Canvas do
    defstruct circles: [], lines: [], selected: nil
  end

  def new_canvas, do: %Canvas{}

  def new_circle(x, y, color \\ "black"), do: %Circle{x: x, y: y, color: color}

  def new_line(x1, y1, x2, y2), do: %StraightLine{x1: x1, y1: y1, x2: x2, y2: y2}

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

  def add_line(canvas, line) do
    %{canvas | lines: [line | canvas.lines]}
  end

  def reset_line(canvas),do: %{canvas| lines: []}
end
