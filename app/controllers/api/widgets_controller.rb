class Api::WidgetsController < Api::BaseController
  def index
    respond_with :api, widgets
  end

  def show
    respond_with :api, widget
  end

  def create
    respond_with :api, widgets.create(widget_params)
  end

  def destroy
    respond_with :api, widget.destroy
  end

  private

  def widgets
    @widgets ||= Widget.all
  end

  def widget
    @widget ||= widgets.find(params[:id])
  end

  def widget_params
    params.permit(:title, :content)
  end
end
