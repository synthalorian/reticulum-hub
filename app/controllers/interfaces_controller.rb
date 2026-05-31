# frozen_string_literal: true

class InterfacesController < ApplicationController
  def index
    rns = RnsAdapter.new
    rns.connect
    @interfaces = rns.interfaces.map { |i| Interface.new(i) }
  end

  def show
    @interface = Interface.find(params[:id])
  end

  def edit
    @interface = Interface.find(params[:id])
  end

  def update
    @interface = Interface.find(params[:id])
    if @interface.update(interface_params)
      redirect_to interfaces_path, notice: "Interface updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def enable
    rns = RnsAdapter.new
    rns.connect
    rns.enable_interface(params[:id])
    redirect_to interfaces_path, notice: "Interface enabled."
  end

  def disable
    rns = RnsAdapter.new
    rns.connect
    rns.disable_interface(params[:id])
    redirect_to interfaces_path, notice: "Interface disabled."
  end

  def restart
    rns = RnsAdapter.new
    rns.connect
    rns.restart_interface(params[:id])
    redirect_to interfaces_path, notice: "Interface restarted."
  end

  private

  def interface_params
    params.require(:interface).permit(:name, :config)
  end
end
