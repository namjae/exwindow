defmodule Window.Timed do
  defstruct duration: nil, items: :queue.new(), flooded?: false

  def time_span(%Window.Timed{items: items}) do
    case {:queue.peek(items), :queue.peek_r(items)} do
      {{:value, {last, _}}, {:value, {first, _}}} -> last - first
      _ -> 0
    end
  end
end

defimpl Windowable, for: Window.Timed do

  def add(window = %Window.Timed{duration: duration, items: items, flooded?: false}, {time, item}) do
    start = time - duration
    left = Enum.take_while(:queue.to_list(items), fn({t, _}) -> t > start end)
    new_window = %{ window | items: :queue.in_r({time, item}, :queue.from_list(left))}
    %{ new_window | flooded?: Enum.count(new_window) <= Enum.count(window)}
  end

  def add(window = %Window.Timed{duration: duration, items: items}, {time, item}) do
    start = time - duration
    left = Enum.take_while(:queue.to_list(items), fn({t, _}) -> t > start end)
    %{ window | items: :queue.in_r({time, item}, :queue.from_list(left))}
  end

  def items(%Window.Timed{items: items}) do
    Enum.map(:queue.to_list(items), fn {_, i} -> i end)
  end
end
