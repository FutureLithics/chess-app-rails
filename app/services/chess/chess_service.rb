# frozen_string_literal: true

class ChessService
  include GameInitializer
  include CpuMoves
  extend MoveDetection  # Change to extend since we're calling these methods as class methods
  extend LogHelper     # Add LogHelper to class methods

  attr_accessor :game

  def initialize(game)
    @game = game
    initialize_pieces
  end

  def self.get_available_moves(piece, pieces, deep = true)
    get_moves_by_piece(piece, pieces, deep)
  end

  def self.cpu_move(cpu_pieces, player_pieces)
    Rails.logger.debug cpu_log("🤖 CPU calculating move")
    new(nil).determine_move(cpu_pieces, player_pieces)
  end

  def self.get_moves_by_piece(piece, pieces, deep = true)
    moves = case piece[:piece_type].to_s.downcase
    when 'pawn'
      get_pawn_moves(piece, pieces)
    when 'knight'
      get_knight_moves(piece, pieces)
    when 'bishop'
      get_bishop_moves(piece, pieces)
    when 'rook'
      get_rook_moves(piece, pieces)
    when 'queen'
      get_queen_moves(piece, pieces)
    when 'king'
      get_king_moves(piece, pieces)
    else
      Rails.logger.error error_log("❌ Unknown piece type: #{piece[:piece_type]}")
      []
    end
    moves
  end

  def self.get_available_moves_by_color(all_pieces, pieces)
    new(nil).get_moves_by_color(all_pieces, pieces)
  end

  def get_moves_by_color(all_pieces, pieces)
    pieces.each do |piece|
      piece[:available_moves] = self.class.get_moves_by_piece(piece, all_pieces)
    end
    pieces
  end

  # Make this a public class method
  def self.get_moves_by_color(all_pieces, pieces)
    Rails.logger.debug cpu_log("🔍 Getting moves for #{pieces.length} pieces")
    pieces.each do |piece|
      piece[:available_moves] = get_moves_by_piece(piece, all_pieces)
      Rails.logger.debug cpu_log("  • #{piece[:piece_type]} at (#{piece[:position_x]},#{piece[:position_y]}) has #{piece[:available_moves].length} moves")
    end
    pieces
  end
end
