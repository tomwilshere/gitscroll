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
    view = 'show'
    @project = Project.find(params[:id])
    @repo = Rugged::Repository.new(@project.repo_local_url)
    @object = @repo.lookup(@repo.head.target.oid).tree

    @path = ''

    if params[:path]
      @path = params[:path]
      @path = @path + '.' + params[:format] if params[:format]
      @object = @repo.lookup(@object.path(@path)[:oid])
      @parent_path = generate_parent_path(@path)
    end

    @commits = @project.commits.order(:date)
    @commit_hash = @commits.group_by { |c| c.git_hash }
    @commit_files = @project.commit_files
      .sort_by { |cf| @commit_hash[cf.commit_id][0].date }
    @file_metrics = @project.file_metrics

    if @object.type == :blob
      view = 'show_file'

      path_commit_files = @project.commit_files
        .where(path: @path).sort_by { |cf| cf.commit.date }
      @commit_files = Hash[path_commit_files
        .map { |cf| [cf.commit_id, cf.id] }]
      @fileCommits = Hash[path_commit_files
        .map { |cf| [cf.commit_id, { commit: cf.commit, file_contents: @repo.lookup(cf.git_hash).content }] }]
      @individual_file_metrics = Hash[path_commit_files.map { |cf| [cf.git_hash, cf.file_metrics] }]
      @metrics = Metric.all
      @json_metric_stats = @project.metric_stats.to_json
      @initial_commit_hash = @fileCommits.keys.last

    else
      @path += '/' if @path != ''
      @d3_network = nil

      puts "generate d3_network #{Time.now.to_f}"
      if @object.type == :tree && @commits.size > 0 && request.format != 'json'
        @d3_network = make_d3_network(@commits.first,
                                      @object,
                                      @path,
                                      @commits.size).to_json
      end

      puts "fetch files_to_fix #{Time.now.to_f}"
      @files_to_fix = @project.fix_files.sort_by { |f| f.score }

      @false_positives = @project.false_positives
      @commit_files_by_path = @commit_files.group_by { |cf| cf.path }
      @commit_files = @commit_files.group_by { |cf| cf.commit_id }
      @file_metrics = @file_metrics.group_by { |fm| fm.commit_file_id }
      @file_metrics.map { |k,v| @file_metrics[k] = Hash[*v.map { |fm| [fm.metric_id, fm] }.flatten] }
      @authors = Hash[@project.authors.uniq.map { |a| [a.id, { name: a.name, email: a.email, email_md5: Digest::MD5.hexdigest(a.email.strip.downcase) }] }]
      @json_metric_stats = MetricStats.all
        .group_by { |ms| ms.project_id }.to_json
    end

    respond_to do |format|
      format.json do
        json_data = { commits: @commits,
                      commit_files: @commit_files,
                      file_metrics: @file_metrics,
                      commit_files_by_path: @commit_files_by_path,
                      authors: @authors }
        render json: json_data
      end
      format.all { render view, formats: [:html], content_type: Mime::HTML }
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
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: 'new' }
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
        format.html { render action: 'edit' }
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
