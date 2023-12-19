defmodule MasterProgrammieraufgabe.MathUtils do
  use Tensor

  def find_diameter(pointset) do
    stream =
      Stream.transform(pointset, pointset, fn _, [cur | rest] ->
        {Enum.map(rest, &{cur, &1}), rest}
      end)
    all_combinations = Enum.into(stream, [])
    distances = Enum.map(all_combinations,fn {{x1,y1},{x2,y2}} -> calculate_distance({x1, y1}, {x2, y2}) end)
    diameter_pair =
      if distances != [] do
        {diameter,idx} = Enum.with_index(distances) |> Enum.max_by(fn ({dist, _idx}) -> dist end)
        {{x1,y1},{x2,y2}}= Enum.at(all_combinations,idx)
        diameter = diameter * :math.sqrt(3) |> Float.ceil(2)
        %{x1: x1, y1: y1, x2: x2, y2: y2, diameter: diameter}
      else
        nil
      end
      diameter_pair
  end

 defp rotate_vector(degree, {v1,v2}=_dir_vec) do
  rad = degree * :math.pi() / 180
  a1 = :math.cos(rad)
  a2 = -:math.sin(rad)
  a3 = :math.sin(rad)
  a4 = :math.cos(rad)
  rot_mat = Matrix.new([[a1,a2],[a3,a4]],2,2)
  rv1 = v1 * rot_mat[0][0] + v2 * rot_mat[0][1]
  rv2 = v1 * rot_mat[1][0] + v2 * rot_mat[1][1]
  {rv1,rv2}
 end

 defp get_rotated_lines({dv1,dv2}=_dir_vec, hull_points,angle) do
    {rv1,rv2} = rotate_vector(angle,{dv1,dv2})
    m = rv2 / rv1
    #get correct hull points line left
    [{p1,p2} | _] = Enum.filter(hull_points, fn point -> check_line_out_of_hull(point,{rv1,rv2},hull_points,true)end)
    #get correct hull points line right
    [{p3,p4} | _] = Enum.filter(hull_points, fn point -> check_line_out_of_hull(point,{rv1,rv2},hull_points,false)end)

    c1 = -m * p1 + p2
    c2 = -m * p3 + p4
    %{x1: x1, y1: y1, x2: x2, y2: y2} = get_crosspoints_with_canvas(m,c1)
    %{x1: x3, y1: y3, x2: x4, y2: y4} = get_crosspoints_with_canvas(m,c2)
    line_1 = %{x1: x1,y1: y1,x2: x2,y2: y2,m: m,c: c1}
    line_2 = %{x1: x3,y1: y3,x2: x4,y2: y4,m: m,c: c2}
    [line_1,line_2]
 end

  def get_helper_lines(%{x1: x1,y1: x2,x2: y1,y2: y2},hull_points) do
  # !!!! handelt noch nicht parralellität zu achsen (m = unendlich)!!!!!
    point1 = {x1,x2}
    point2 = {y1,y2}
    {ov1, ov2} = calc_orthogonal_vec(point1,point2)

    [line1,line2] = get_rotated_lines({ov1,ov2},hull_points,0)
    [line3,line4] = get_rotated_lines({ov1,ov2},hull_points,60)
    [line5,line6] = get_rotated_lines({ov1,ov2},hull_points,120)
    triangle_coords = get_triangle([line1,line4,line5])

    [[line1,line2,line3,line4,line5,line6],triangle_coords]
  end

  def get_triangle([line1,line2,line3] = lines) do
    %{m: m1,c: c1} = line1
    %{m: m2,c: c2} = line2
    %{m: m3,c: c3} = line3

    #Crosspoints of line1 and line2
    x1 = (c2 - c1) / (m1 - m2)
    y1 = m1 * x1 + c1
    #Crosspoints of line2 and line3
    x2 = (c3 - c2) / (m2 - m3)
    y2 = m2 * x2 + c2
    #Crosspoints of line1 and line3
    x3 = (c3 - c1) / (m1 - m3)
    y3 = m1 * x3 + c1

    distance = calculate_distance({x1,y1},{x2,y2}) |> Float.ceil(2)

    %{x1: x1,y1: y1,x2: x2,y2: y2,x3: x3,y3: y3, distance: distance}
  end

  defp check_line_out_of_hull({f1,f2} = point,{rv1,rv2}=_dir_vec,hull_points,left) do
    {d1,d2} = {f1+rv1,f2+rv2}
    res = Enum.reduce(hull_points,true,fn {p1,p2},acc -> is_left?({f1,f2},{d1,d2},{p1,p2}) == left and acc == true or (point == {p1,p2} and acc == true)end)
    res
  end


  defp get_crosspoints_with_canvas(m,c) do
    # canvas limits
    x_left = 0
    x_right = 100
    y_top = 0
    y_bottom = 100

    cp_left = m * x_left + c
    cp_right = m * x_right + c
    cp_top = (y_top-c)/ m
    cp_bottom = (y_bottom-c)/ m
    l = [cp_left,cp_right,cp_top,cp_bottom]
    [cp1,cp2]= Enum.with_index(l) |> Enum.filter( fn {value,_idx} -> value > 0 and value < 100 end)
    {cp1_x,cp1_y} = format_crosspoint(cp1)
    {cp2_x,cp2_y} = format_crosspoint(cp2)

    %{x1: cp1_x,y1: cp1_y,x2: cp2_x,y2: cp2_y}
  end

  defp format_crosspoint({val, idx} = _cp) do
    point =
      cond  do
        idx === 0 ->
          {0,val}
        idx === 1 ->
          {100,val}
        idx === 2 ->
          {val,0}
        idx === 3 ->
          {val,100}
      end
    point
  end

  defp calc_orthogonal_vec({a1,a2}=_point1,{b1,b2}=_point2) do
    x1 = b1 - a1
    x2 = b2 - a2
    {-x2,x1}
  end

  def graham_scan(pointset) do
    smallest_ordinate = find_smallest_ordinate(pointset)
    pointset_without_ordinate = Enum.filter(pointset,fn point -> point != smallest_ordinate end)
    [p1|sorted_points] = sort_points_by_angle(smallest_ordinate,pointset_without_ordinate)
    stack = [smallest_ordinate]
    stack = [p1|stack]
    hull_points = get_hull_points(stack, sorted_points)
    hull_points
  end


  defp find_smallest_ordinate(pointset) do
      point = Enum.min_by(pointset,fn {_,y} -> y end)
      point
  end

  defp sort_points_by_angle({px,py},pointset) do
    vector_set = Enum.map(pointset,fn {x,y} -> {x-px, y-py} end)
    angle_set = Enum.map(vector_set,fn {x,y} -> get_angle({1,0},{x,y})end) |> Enum.zip(pointset) |> Enum.sort(fn ({angle,{_,_}},{angle2,{_,_}}) -> angle < angle2 end )
    sorted_points = Enum.map(angle_set, fn {_angle,point} -> point end)
    sorted_points
  end


  defp get_angle(vec1 , vec2) do
    dp = dot_product(vec1,vec2)
    m1 = magnitude(vec1)
    m2 = magnitude(vec2)
    :math.acos(dp / (m1 * m2))
  end

  defp magnitude({x1,y1}=_vector1) do
   m = :math.sqrt(x1 * x1 + y1 * y1)
   m
  end

  defp dot_product({x1,y1}=_vector1, {x2,y2}=_vector2) do
    dp = x1 * x2 + y1 * y2
    dp
  end

  defp get_hull_points(stack, sorted_points) do
    [pt1|[pt2|tail]] = stack
    [si|tail_sorted_points] = sorted_points
    {stack,sorted_points} = if is_left?(pt2 ,pt1 , si) or tail === [] do
      {[si|stack],tail_sorted_points}
    else
      {[pt2|tail],sorted_points}
    end
    if sorted_points === [] do
      stack
    else
      get_hull_points(stack,sorted_points)
    end
  end

  defp is_left?({x1,y1},{x2,y2},{x3,y3}) do
    val = (x2 - x1)*(y3 - y1) - (x3 - x1) * (y2 - y1)
    val > 0
  end

  defp calculate_distance({x1, y1}, {x2, y2}) do
    distance = :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
    distance
  end


end
