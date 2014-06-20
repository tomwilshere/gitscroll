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

    puts "sort commits " + Time.now.to_f.to_s
    @commits = @project.commits.order(:date)
    # if @commits.size >= 1000
    #   @commits = @commits[@commits.size - 1000, @commits.size]
    # end
    puts "group commits " + Time.now.to_f.to_s
    @commitHash = @commits.group_by{|c| c.git_hash }
    puts "sort commitFiles " + Time.now.to_f.to_s
    @commitFiles = @project.commit_files.sort_by { |cf| @commitHash[cf.commit_id][0].date }
    puts "fetch fileMetrics " + Time.now.to_f.to_s
    @fileMetrics = @project.file_metrics

    if @object.type == :blob
      view = "show_file"

      pathCommitFiles = @project.commit_files.where(:path => @path).sort_by{ |cf| cf.commit.date}

      @commitFiles = Hash[pathCommitFiles.map{|cf| [cf.commit_id, cf.id]}]

      @fileCommits = Hash[pathCommitFiles.map{|cf| [cf.commit_id, {:commit => cf.commit, :file_contents => @repo.lookup(cf.git_hash).content}]}]

      @individual_file_metrics = Hash[pathCommitFiles.map{|cf| [cf.git_hash, cf.file_metrics]}]

      @metrics = Metric.all

      @jsonMetricStats = @project.metric_stats.to_json

      @initial_commit_hash = @fileCommits.keys.last

    else
      if @path != ""
        @path += "/"
      end
      @d3Network = nil

      puts "generate d3Network " + Time.now.to_f.to_s
      if @object.type == :tree && @commits.size > 0 && request.format != "json"
        @d3Network = makeD3Network(@commits.first, @object, @path, @commits.size).to_json
      end

      puts "fetch filesToFix " + Time.now.to_f.to_s
      @filesToFix = @project.fix_files.sort_by{|f| f.score}

      @falsePositives = @project.false_positives
      @jsonCommits = @commits.to_json
      @commitFilesByPath = @commitFiles.group_by{|cf| cf.path}
      @jsonCommitFilesByPath = @commitFilesByPath.to_json
      @commitFiles = @commitFiles.group_by{|cf| cf.commit_id }
      @jsonCommitFiles = @commitFiles.to_json
      @fileMetrics = @fileMetrics.group_by{|fm| fm.commit_file_id}
      @fileMetrics.map{|k,v| @fileMetrics[k] = Hash[*v.map{|fm| [fm.metric_id, fm]}.flatten]}
      @jsonFileMetrics = @fileMetrics.to_json
      @authors = Hash[@project.authors.uniq.map{|a| [a.id, {name: a.name, email: a.email, email_md5: Digest::MD5.hexdigest(a.email.strip.downcase)}]}]
      @jsonMetricStats = MetricStats.all.group_by{|ms| ms.project_id}.to_json
    end

    respond_to do |format|
      format.json { render json: {commits: @commits, commit_files: @commitFiles, file_metrics: @fileMetrics, commit_files_by_path: @commitFilesByPath, authors: @authors} }
      format.all { render view, :formats => [:html], :content_type => Mime::HTML }
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
