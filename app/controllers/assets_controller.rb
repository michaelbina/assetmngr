class AssetsController < ApplicationController
  # GET /assets
  # GET /assets.json
  def index
    @assets = Asset.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assets }
    end
  end

  # GET /assets/1
  # GET /assets/1.json
  def show
    @asset = Asset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @asset }
    end
  end

  # GET /assets/new
  # GET /assets/new.json
  def new
    @asset = Asset.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @asset }
    end
  end

  # GET /assets/1/edit
  def edit
    @asset = Asset.find(params[:id])
  end

  # POST /assets
  # POST /assets.json
  def create
    @asset = Asset.new(params[:asset])

    respond_to do |format|
      if @asset.save
        format.html { redirect_to assets_url, notice: 'Asset was successfully created.' }
        format.json { render json: @asset, status: :created, location: @asset }
      else
        format.html { render action: "new" }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assets/1
  # PUT /assets/1.json
  def update
    @asset = Asset.find(params[:id])

    respond_to do |format|
      if @asset.update_attributes(params[:asset])
        format.html { redirect_to @asset, notice: 'Asset was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assets/1
  # DELETE /assets/1.json
  def destroy
    @asset = Asset.find(params[:id])
    @asset.destroy

    respond_to do |format|
      format.html { redirect_to assets_url }
      format.json { head :no_content }
    end
  end

  #
  # Get all tags in the system currently
  #
  # GET /tags
  # GET /tags.json
  def tags
    @tags_with_count = Asset.tag_counts_on(:tags)
    
    @tags = @tags_with_count.map{|tag_hash| tag_hash = tag_hash.name }
    
    respond_to do |format|
      format.html
      format.json  { render :json => @tags }
    end
  end
  
  #
  # Get all assets with a specific tag
  #
  # GET /tag/#{tag}
  # GET /tag/#{tag}.json
  def tag
    @assets = Asset.tagged_with(params[:tag])
    @tag = params[:tag]
    
    
    respond_to do |format|
      format.html { render :index }
      format.json  { render :json => @assets }
    end
  end
  
  #
  # Add a tag to the specified asset
  #
  # PUT /assets/:id/add_tag
  # PUT /assets/:id/add_tag.json
  def add_tag
    @asset = Asset.find(params[:id])
    new_tag = params[:tag]
    
    if @asset.tag_list.include?(new_tag)
      render :nothing => true
      return
    end
    
    @asset.tag_list << new_tag
    
    tag_html = render_to_string :partial => "shared/tag.html.haml", :locals => { :asset => @asset, :tag_name => new_tag }
    
    respond_to do |format|
      if @asset.save
        format.html { redirect_to(@asset, :notice => 'Tag was successfully added to asset.') }
        format.json  { render :json => { :asset => @asset, :tag_html => tag_html } }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  #
  # Remove a tag from the specified asset
  #
  # DELETE /posts/1/remove_tag
  # DELETE /posts/1/remove_tag.json
  def remove_tag
    @asset = Asset.find(params[:id])
    tag_to_remove = params[:tag]
    
    @asset.tags = @asset.tags.select{|tag| tag.name != tag_to_remove}
    
    respond_to do |format|
      if @asset.save
        format.html { redirect_to(assets_url, :notice => 'Tag was successfully removed from asset.') }
        format.json  { render :json => @asset }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @asset.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  #
  # add a number of assets to the system with file uploads
  # files and the count of files should be passed through the params in the following format:
  # params = ["file-1" => #File, "file-2" => #File ... "file-n" => #File, :count => 'n']
  #
  # POST /assets/add_assets
  # POST /assets/add_assets.json
  def add_assets
    num_files = params[:count].to_i
    
    @new_assets = []
    @new_assets_html = []
    num_files.times do |file_num|
      # recreate the file key from the current index
      file = params["file-"+file_num.to_s]
      @asset = Asset.new(:name => file.original_filename)
      @asset.save
      @asset.save_file(file)
      
      @new_assets.push(@asset)
      # render the html to add to the page for the json response
      asset_html = render_to_string :partial => "shared/asset.html.haml", :locals => { :asset => @asset }
      @new_assets_html.push(asset_html)
    end

    respond_to do |format|
      format.html { redirect_to assets_url, notice: 'Asset was successfully created.' }
      format.json { render json: {:assets => @new_assets, :assets_html => @new_assets_html, status: :created} }
    end

  end
  
  
end
