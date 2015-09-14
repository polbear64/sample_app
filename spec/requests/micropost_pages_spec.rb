require 'spec_helper'

describe "Micropost Pages" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button  "Post" }
        it {should have_content('error') }
      end
    end

    describe "with valid information" do

      before { fill_in 'micropost_content', with: "Lorem ipsum" }
      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
      end
      
      describe "and have one post" do
        before { click_button "Post" }
        it { should have_content("1 micropost") }
        it { should_not have_content("1 microposts") }
      end

      describe "and have two posts" do
        before do
          click_button "Post"
          fill_in 'micropost_content', with: "Lorem ipsum2"
          click_button "Post"
        end

        it { should have_content("2 microposts") }
      end
    end
  end

  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
    end
  end

  describe "pagination" do

    before do
      40.times { FactoryGirl.create(:micropost, user: user) }
      visit root_path
    end

    after(:all) { Micropost.delete_all }

    it { should have_selector('div.pagination') }
    
    it "should list each micropost" do
      user.microposts.paginate(page: 1).each do |micropost|
        expect(page).to have_selector('li', text: micropost.content)
      end
    end
  end

  describe "user doesn't have delete link to micropost of another user" do
      
    let!(:m1){ FactoryGirl.create(:micropost, user: user) }
    before { visit user_path(user) }
    it { should have_link("delete")}

    describe "micropost delete link" do
      let(:invalid_user) { FactoryGirl.create(:user, name: "foo", email: "bar@example.com") }
      
      let!(:invalid_m1){ FactoryGirl.create(:micropost, user: invalid_user, content: "Foo") }
      before { visit user_path(invalid_user) }
      
      it { should_not have_link("delete") }
    end
  end
end
