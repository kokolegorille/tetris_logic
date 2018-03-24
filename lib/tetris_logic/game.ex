defmodule TetrisLogic.Game do
  @moduledoc false
  
  alias TetrisLogic.Shapes
  alias TetrisLogic.Game.{State, Interaction}
  
  def new() do
    seed_random_number_generator()
    build_state()
  end
  
  def tally(state) do
    next = state.next
    |> Shapes.get(0) 
    |> colorize(state.next)
    
    %{
      board: board_with_overlaid_shape(state), 
      next: next,
      points: state.points,
      active: state.active,
      statistics: state.statistics
    }
  end
  
  def handle_input(state, input) do
    Interaction.handle_input(state, input)
  end
  
  def tick(state) do
    tick_game(state)
  end
  
  # Private
  
  defp board_with_overlaid_shape(%State{} = state) do
    for {row, row_i} <- Enum.with_index(state.board) do
      for {col, col_i} <- Enum.with_index(row) do
        rotated_shape_overlaps_cell = Enum.member?(State.cells_for_shape(state), {col_i, row_i})
        cond do
          rotated_shape_overlaps_cell -> Shapes.number(state.current)
          true -> col
        end
      end
    end
  end

  defp tick_game(state) do
    cond do
      collision_with_bottom?(state) || collision_with_board?(state) ->
        new_state = %State{state | board: board_with_overlaid_shape(state) }
        cleared_state = State.clear_lines(new_state)
        active = State.still_playable?(new_state)
        next = Shapes.random
        statistics = Map.update(state.statistics, next, 1, & &1 + 1)
        
        %State{cleared_state | 
          current: state.next, 
          x: 5, y: 0, 
          next: next, 
          rotation: 0,
          active: active,
          statistics: statistics
        }
      :else ->
        %State{state | y: state.y + 1}
    end
  end

  defp collision_with_bottom?(state) do
    Shapes.height(state.current, state.rotation) + state.y > 19
  end

  defp collision_with_board?(state) do
    next_coords = for {x, y} <- State.cells_for_shape(state), do: {x, y+1}
    Enum.any?(next_coords, fn(coords) ->
      State.cell_at(state, coords) != 0
    end)
  end

  defp colorize(shape_list, name) do
    for row <- shape_list do
      for col <- row do
        col * Shapes.number(name)
      end
    end
  end
  
  defp seed_random_number_generator do
    <<a::size(32), b::size(32), c::size(32)>> = :crypto.strong_rand_bytes(12)
    :rand.seed(:exs1024, {a, b, c})
  end
  
  defp build_state() do
    next = Shapes.random;
    current = Shapes.random;
    statistics = [next, current] 
      |> Enum.reduce(%{}, fn piece, map ->
           Map.update(map, piece, 1, & &1 + 1)
         end)
    
		%State{
			board: [
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0],
				[0,0,0,0,0,0,0,0,0,0]
			],
			next: next,
			current: current,
			rotation: 0,
			x: 5,
			y: 0,
      active: true,
      points: 0,
      statistics: statistics
		}
  end
end