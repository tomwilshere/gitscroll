class ProjectsController < ApplicationController

  include ProjectsHelper
  include MetricsHelper
  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    view = "show"
    @project = Project.find(params[:id])
    @repo = Rugged::Repository.new(@project.repo_local_url)
    @object = @repo.lookup(@repo.head.target.oid).tree
    
    @path = ""
    
    if params[:path] != nil
      @path = params[:path]
      if params[:format]
        @path = @path + "." + params[:format]
      end
      @object = @repo.lookup(@object.path(@path)[:oid])
      @parent_path = generate_parent_path(@path)
    end

    @commits = @project.commits.sort_by{|c| c.date}
    @commitFiles = @project.commit_files.sort_by { |cf| cf.commit.date }
    @fileMetrics = @project.file_metrics

    if @object.type == :blob
      view = "show_file"

      @fileCommits = Hash[@commitFiles.map{|cf| [cf.commit_id, {:commit => cf.commit, :file_contents => @repo.lookup(cf.git_hash).content}]}]

      if @commitFiles.size > 1
        data_table = GoogleVisualr::DataTable.new
        data_table.new_column('datetime', 'date')
        # data_table.new_column('number', 'flog')
        Metric.all.each do |metric|
          data_table.new_column('number', metric.name)
        end
        
        metric_data = []

        @commitFiles.each do |cf|
          commit = cf.commit
          metrics = cf.file_metrics
          file_metric_data = [DateTime.parse(commit.date.to_s)]
          Metric.all.each do |metric|
            individual_metric_data = metrics.where(:metric_id => metric.id)
            if individual_metric_data.size > 0
              file_metric_data.push(individual_metric_data.first.score)
            else
              file_metric_data.push(nil)
            end
          end
          metric_data.push(file_metric_data)
        end
        puts "METRIC DATA: " + metric_data.to_s
        data_table.add_rows(metric_data)

        option = { width: "100%", height: 300, title: 'Metrics' }
        @chart = GoogleVisualr::Interactive::LineChart.new(data_table,option)
      end

      @initial_commit_hash = @fileCommits.keys.first

    elsif @path != ""
      @path += "/"
    end

    @d3Network = nil

    if @object.type == :tree && @commits.size > 0 && request.format != "json"
      @d3Network = makeD3Network(@commits.first, @object, @path, @commits.size).to_json
    end

    @jsonCommits = @commits.to_json
    @commitFilesByPath = @commitFiles.group_by{|cf| cf.path}
    @jsonCommitFilesByPath = @commitFilesByPath.to_json
    @commitFiles = @commitFiles.group_by{|cf| cf.commit_id }
    @jsonCommitFiles = @commitFiles.to_json
    @fileMetrics = @fileMetrics.group_by{|fm| fm.commit_file_id}
    @jsonFileMetrics = @fileMetrics.to_json
    @jsonMetricStats = MetricStats.all.group_by{|ms| ms.project_id}.to_json

    respond_to do |format|
      format.json { render json: {commits: @commits, commit_files: @commitFiles, file_metrics: @fileMetrics, commit_files_by_path: @commitFilesByPath} }
      format.all { render view }
    end
  end


  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    @project.init

    respond_to do |format|
      if @project.save
        Resque.enqueue(MetricUpdater, @project.id)
        # update_metrics(@project)
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = Project.find(params[:id])
    FileUtils.rm_rf Dir.glob(@project.repo_local_url)
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :repo_local_url, :repo_remote_url)
  end

end
