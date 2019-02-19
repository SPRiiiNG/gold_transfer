class TransactionsController < ApplicationController
  before_action :authenticate_staff!
  before_action :get_transaction, only: [:approve, :reject]

  def index
    @transactions = Transaction.by_cash.where(status: 'pending').includes(:transaction_transfers).order(created_at: :desc)
    @completed_transactions = Transaction.by_cash.where(status: 'completed').includes(:transaction_transfers).order(created_at: :desc)
    @rejected_transactions = Transaction.by_cash.where(status: 'rejected').includes(:transaction_transfers).order(created_at: :desc)
  end

  def approve
    redirect_to transactions_path and return unless @transaction
    @transaction.approve!
    @transaction.save
    redirect_to transactions_path
  end

  def reject
    redirect_to transactions_path and return unless @transaction
    @transaction.reject!
    @transaction.save
    redirect_to transactions_path
  end

  private
  def get_transaction
    @transaction = Transaction.where(id: params[:id]).first
  end
end
