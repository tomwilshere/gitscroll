module ProjectsHelper
	def generate_parent_path(path)
		parent_path = @path.split("/")
      	parent_path.pop
      	return parent_path.join("/")
    end
end
