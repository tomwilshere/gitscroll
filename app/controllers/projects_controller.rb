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

    @fileCommits = Hash.new

    if @object.type == :blob
      view = "show_file"
      commitFiles = @project.commit_files.where(:path => @path)

      @fileCommits = Hash[commitFiles.map{|cf| [cf.commit_id, {:commit => cf.commit, :file_contents => @repo.lookup(cf.git_hash).content}]}]

      if commitFiles.size > 1
        data_table = GoogleVisualr::DataTable.new
        data_table.new_column('datetime', 'date')
        # data_table.new_column('number', 'flog')
        data_table.new_column('number', 'Number of lines')
        data_table.new_column('number', 'wilt')
        data_table.new_column('number', 'rubocop')
        
        metric_data = []

        commitFiles.each do |cf|
          commit = cf.commit
          metrics = cf.file_metrics
          metric_data.push([DateTime.parse(commit.date.to_s),
                            metrics.where(:metric_id => 3).first.score,
                            metrics.where(:metric_id => 2).first.score,
                            # metrics.where(:metric_id => 4).first.score
                            ])
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

    if @object.type == :tree
      @d3Network = makeD3Network(@object, @path.split("/").last).to_json
    end

    puts @fileCommits.size
    render view
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
    # This is a hack to make it work - investigate asynchronous metric updating.
    update_metrics(@project)

    respond_to do |format|
      if @project.save
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
