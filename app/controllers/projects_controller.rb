class ProjectsController < ApplicationController
  include ProjectsHelper
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
    @object = @repo.lookup(@repo.head.target).tree
    
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
      walker = Rugged::Walker.new(@repo)
      walker.push(@repo.head.target)
      walker.each do |commit|
        file = nil
        begin
          file = commit.tree.path(@path)
        rescue

        end
        if file != nil
          @fileCommits[commit.oid] = {:commit => commit, :file_contents => @repo.lookup(file[:oid]).content}
        end

      end

      @initial_commit_hash = @fileCommits.keys.first

    elsif @path != ""
      @path += "/"
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
    @project = Project.new(params[:project])

    @project.init

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
end
