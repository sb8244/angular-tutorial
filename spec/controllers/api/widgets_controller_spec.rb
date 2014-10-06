RSpec.describe Api::WidgetsController, type: :controller do
  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe 'GET index' do
    let!(:widget) { Widget.create!(title: "Test", content: "Test") }
    let!(:widget2) { Widget.create!(title: "Test2", content: "Test2") }

    it "lists the widgets" do
      get :index
      expect(response_json.count).to eq(2)
      expect(response_json.first["id"]).to eq(widget.id)
    end
  end

  describe 'GET show' do
    let!(:widget) { Widget.create!(title: "Test", content: "Test") }
    let!(:widget2) { Widget.create!(title: "Test2", content: "Test2") }

    it "shows the widget" do
      get :show, id: widget2.id
      expect(response_json["id"]).to eq(widget2.id)
    end
  end

  describe 'POST create' do
    it "creates a widget" do
      expect {
        post :create, title: "Test", content: "Tester"
      }.to change{ Widget.count }.by(1)
    end
  end

  describe 'DELETE destroy' do
    let!(:widget) { Widget.create!(title: "Test", content: "Test") }

    it "removes the widget" do
      expect {
        delete :destroy, id: widget.id
      }.to change{ Widget.count }.by(-1)
    end
  end
end
