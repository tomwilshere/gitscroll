class FalsePositivesController < ApplicationController
  before_action :set_false_positive, only: [:show, :edit, :update, :destroy]

  # GET /false_positives
  def index
    @false_positives = FalsePositive.all
    respond_to do |format|
      format.html
      format.json { render json: @false_positives }
    end
  end

  # GET /false_positives/1
  def show
  end

  # GET /false_positives/new
  def new
    @false_positive = FalsePositive.new
  end

  # GET /false_positives/1/edit
  def edit
  end

  # POST /false_positives
  def create
    @false_positive = FalsePositive.new(false_positive_params)

    if @false_positive.save
      render json: @false_positive
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /false_positives/1
  def update
    if @false_positive.update(false_positive_params)
      redirect_to @false_positive, notice: 'False positive was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /false_positives/1
  def destroy
    @false_positive.destroy
    redirect_to false_positives_url, notice: 'False positive was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_false_positive
    @false_positive = FalsePositive.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def false_positive_params
    params.require(:false_positive).permit(:path, :project_id, :comment, :type)
  end
end
