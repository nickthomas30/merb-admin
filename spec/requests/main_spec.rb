require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

given "a player exists" do
  @player = MerbAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => rand(99), :name => "Player 1", :sex => :male, :position => :pitcher)
end

given "a draft exists" do
  @draft = MerbAdmin::AbstractModel.new("Draft").create(:player_id => rand(99999), :team_id => rand(99999), :date => Date.today, :round => rand(50), :pick => rand(30), :overall => rand(1500))
end

given "two players exist" do
  @players = []
  2.times do |i|
    @players << MerbAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => rand(99), :name => "Player #{i}", :sex => :male, :position => :pitcher)
  end
end

given "three teams exist" do
  @teams = []
  3.times do |i|
    @teams << MerbAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{i}")
  end
end

given "a player exists and a draft exists" do
  @player = MerbAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => rand(99), :name => "Player 1", :sex => :male, :position => :pitcher)
  @draft = MerbAdmin::AbstractModel.new("Draft").create(:player_id => rand(99999), :team_id => rand(99999), :date => Date.today, :round => rand(50), :pick => rand(30), :overall => rand(1500))
end

given "a player exists and three teams exist" do
  @player = MerbAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => rand(99), :name => "Player 1", :sex => :male, :position => :pitcher)
  @teams = []
  3.times do |i|
    @teams << MerbAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{i}")
  end
end

given "a league exists and three teams exist" do
  @league = League.create(:name => "League 1")
  @teams = []
  3.times do |i|
    @teams << MerbAdmin::AbstractModel.new("Team").create(:league_id => rand(99999), :division_id => rand(99999), :name => "Team #{i}")
  end
end

given "twenty players exist" do
  @players = []
  20.times do |i|
    @players << MerbAdmin::AbstractModel.new("Player").create(:team_id => rand(99999), :number => rand(99), :name => "Player #{i}", :sex => :male, :position => :pitcher)
  end
end

describe "MerbAdmin" do

  before(:each) do
    mount_slice
    MerbAdmin::AbstractModel.new("Division").destroy_all!
    MerbAdmin::AbstractModel.new("Draft").destroy_all!
    MerbAdmin::AbstractModel.new("League").destroy_all!
    MerbAdmin::AbstractModel.new("Player").destroy_all!
    MerbAdmin::AbstractModel.new("Team").destroy_all!
  end

  describe "dashboard" do
    before(:each) do
      @response = request(url(:admin_dashboard))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"Site administration\"" do
      @response.body.should contain("Site administration")
    end
  end

  describe "list" do
    before(:each) do
      @response = request(url(:admin_list, :model_name => "player"))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"Select model to edit\"" do
      @response.body.should contain("Select player to edit")
    end
  end

  describe "list with 2 objects", :given => "two players exist" do
    before(:each) do
      MerbAdmin[:paginate] = true
      MerbAdmin[:per_page] = 1
      @response = request(url(:admin_list, :model_name => "player"))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"2 results\"" do
      @response.body.should contain("2 players")
    end
  end

  describe "list with 20 objects", :given => "twenty players exist" do
    before(:each) do
      MerbAdmin[:paginate] = true
      MerbAdmin[:per_page] = 1
      @response = request(url(:admin_list, :model_name => "player"))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"20 results\"" do
      @response.body.should contain("20 players")
    end
  end

  describe "list with 20 objects, page 8", :given => "twenty players exist" do
    before(:each) do
      MerbAdmin[:paginate] = true
      MerbAdmin[:per_page] = 1
      @response = request(url(:admin_list, :model_name => "player"), :params => {:page => 8})
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should paginate correctly" do
      @response.body.should contain(/1 2[^0-9]*5 6 7 8 9 10 11[^0-9]*19 20/)
    end
  end

  describe "list with 20 objects, page 17", :given => "twenty players exist" do
    before(:each) do
      MerbAdmin[:paginate] = true
      MerbAdmin[:per_page] = 1
      @response = request(url(:admin_list, :model_name => "player"), :params => {:page => 17})
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should paginate correctly" do
      @response.body.should contain(/1 2[^0-9]*12 13 14 15 16 17 18 19 20/)
    end
  end

  describe "list show all", :given => "two players exist" do
    before(:each) do
      MerbAdmin[:paginate] = true
      MerbAdmin[:per_page] = 1
      @response = request(url(:admin_list, :model_name => "player"), :params => {:all => true})
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end
  end

  describe "new" do
    before(:each) do
      @response = request(url(:admin_new, :model_name => "player"))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"New model\"" do
      @response.body.should contain("New player")
    end
  end

  describe "new with has-one association", :given => "a draft exists" do
    before(:each) do
      @response = request(url(:admin_new, :model_name => "player"))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end
  end

  describe "new with has-many association", :given => "three teams exist" do
    before(:each) do
      @response = request(url(:admin_new, :model_name => "player"))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end
  end

  describe "edit", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_edit, :model_name => "player", :id => @player.id))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"Edit model\"" do
      @response.body.should contain("Edit player")
    end
  end

  describe "edit with has-one association", :given => "a player exists and a draft exists" do
    before(:each) do
      @response = request(url(:admin_edit, :model_name => "player", :id => @player.id))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end
  end

  describe "edit with has-many association", :given => "a player exists and three teams exist" do
    before(:each) do
      @response = request(url(:admin_edit, :model_name => "player", :id => @player.id))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end
  end


  describe "edit with missing object" do
    before(:each) do
      @response = request(url(:admin_edit, :model_name => "player", :id => 1))
    end

    it "should raise NotFound" do
      @response.status.should == 404
    end
  end

  describe "create" do
    before(:each) do
      @response = request(url(:admin_create, :model_name => "player"), :method => "post", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :position => :second, :sex => :male}})
    end

    it "should redirect to list" do
      @response.should redirect_to(url(:admin_list, :model_name => "player"))
    end

    it "should create a new object" do
      MerbAdmin::AbstractModel.new("Player").first.should_not be_nil
    end
  end

  describe "create and edit" do
    before(:each) do
      @response = request(url(:admin_create, :model_name => "player"), :method => "post", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :position => :second, :sex => :male}, :_continue => true})
    end

    it "should redirect to edit" do
      @response.should redirect_to(url(:admin_edit, :model_name => "player", :id => MerbAdmin::AbstractModel.new("Player").first.id))
    end

    it "should create a new object" do
      MerbAdmin::AbstractModel.new("Player").first.should_not be_nil
    end
  end

  describe "create and add another" do
    before(:each) do
      @response = request(url(:admin_create, :model_name => "player"), :method => "post", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :position => :second, :sex => :male}, :_add_another => true})
    end

    it "should redirect to new" do
      @response.should redirect_to(url(:admin_new, :model_name => "player"))
    end

    it "should create a new object" do
      MerbAdmin::AbstractModel.new("Player").first.should_not be_nil
    end
  end

  describe "create with has-one association", :given => "a draft exists" do
    before(:each) do
      @response = request(url(:admin_create, :model_name => "player"), :method => "post", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :position => :second, :sex => :male}, :associations => {:draft => @draft.id}})
    end

    it "should create a new object" do
      MerbAdmin::AbstractModel.new("Player").first.should_not be_nil
    end

    it "should be associated with the correct object" do
      MerbAdmin::AbstractModel.new("Player").first.draft.should == @draft
    end
  end

  describe "create with has-many association", :given => "three teams exist" do
    before(:each) do
      @response = request(url(:admin_create, :model_name => "league"), :method => "post", :params => {:league => {:name => "National League"}, :associations => {:teams => [@teams[0].id, @teams[1].id]}})
    end

    it "should create a new object" do
      MerbAdmin::AbstractModel.new("League").first.should_not be_nil
    end

    it "should be associated with the correct objects" do
      MerbAdmin::AbstractModel.new("League").first.teams.should include(@teams[0])
      MerbAdmin::AbstractModel.new("League").first.teams.should include(@teams[1])
    end

    it "should be not associated with an incorrect object" do
      MerbAdmin::AbstractModel.new("League").first.teams.should_not include(@teams[2])
    end
  end

  describe "create with invalid object" do
    before(:each) do
      @response = request(url(:admin_create, :model_name => "player"), :method => "post", :params => {:player => {}})
    end

    it "should contain an error message" do
      @response.body.should contain("Player failed to be created")
    end
  end

  describe "update", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "player", :id => @player.id), :method => "put", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :sex => :male}})
    end

    it "should redirect to list" do
      @response.should redirect_to(url(:admin_list, :model_name => "player"))
    end

    it "should update an object that already exists" do
      MerbAdmin::AbstractModel.new("Player").first.name.should eql("Jackie Robinson")
    end
  end

  describe "update and edit", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "player", :id => @player.id), :method => "put", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :sex => :male}, :_continue => true})
    end

    it "should redirect to edit" do
      @response.should redirect_to(url(:admin_edit, :model_name => "player", :id => @player.id))
    end

    it "should update an object that already exists" do
      MerbAdmin::AbstractModel.new("Player").first.name.should eql("Jackie Robinson")
    end
  end

  describe "update and add another", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "player", :id => @player.id), :method => "put", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :sex => :male}, :_add_another => true})
    end

    it "should redirect to new" do
      @response.should redirect_to(url(:admin_new, :model_name => "player"))
    end

    it "should update an object that already exists" do
      MerbAdmin::AbstractModel.new("Player").first.name.should eql("Jackie Robinson")
    end
  end

  describe "update with has-one association", :given => "a player exists and a draft exists" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "player", :id => @player.id), :method => "put", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :position => :second, :sex => :male}, :associations => {:draft => @draft.id}})
    end

    it "should update an object that already exists" do
      MerbAdmin::AbstractModel.new("Player").first.name.should eql("Jackie Robinson")
    end

    it "should be associated with the correct object" do
      MerbAdmin::AbstractModel.new("Player").first.draft.should == @draft
    end
  end

  describe "update with has-many association", :given => "a league exists and three teams exist" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "league", :id => @league.id), :method => "put", :params => {:league => {:name => "National League"}, :associations => {:teams => [@teams[0].id, @teams[1].id]}})
    end

    it "should update an object that already exists" do
      MerbAdmin::AbstractModel.new("League").first.name.should eql("National League")
    end

    it "should be associated with the correct objects" do
      MerbAdmin::AbstractModel.new("League").first.teams.should include(@teams[0])
      MerbAdmin::AbstractModel.new("League").first.teams.should include(@teams[1])
    end

    it "should not be associated with an incorrect object" do
      MerbAdmin::AbstractModel.new("League").first.teams.should_not include(@teams[2])
    end
  end

  describe "update with missing object" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "player", :id => 1), :method => "put", :params => {:player => {:name => "Jackie Robinson", :number => 42, :team_id => 1, :sex => :male}})
    end

    it "should raise NotFound" do
      @response.status.should == 404
    end
  end

  describe "update with invalid object", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_update, :model_name => "player", :id => @player.id), :method => "put", :params => {:player => {:number => "a"}})
    end

    it "should contain an error message" do
      @response.body.should contain("Player failed to be updated")
    end
  end

  describe "delete", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_delete, :model_name => "player", :id => @player.id))
    end

    it "should respond sucessfully" do
      @response.should be_successful
    end

    it "should contain \"Delete model\"" do
      @response.body.should contain("Delete player")
    end
  end

  describe "delete with missing object" do
    before(:each) do
      @response = request(url(:admin_delete, :model_name => "player", :id => 1))
    end

    it "should raise NotFound" do
      @response.status.should == 404
    end
  end

  describe "destroy", :given => "a player exists" do
    before(:each) do
      @response = request(url(:admin_destroy, :model_name => "player", :id => @player.id), :method => "delete")
    end

    it "should redirect to list" do
      @response.should redirect_to(url(:admin_list, :model_name => "player"))
    end

    it "should destroy an object" do
      MerbAdmin::AbstractModel.new("Player").first.should be_nil
    end
  end

  describe "destroy with missing object" do
    before(:each) do
      @response = request(url(:admin_destroy, :model_name => "player", :id => 1), :method => "delete")
    end

    it "should raise NotFound" do
      @response.status.should == 404
    end
  end

end