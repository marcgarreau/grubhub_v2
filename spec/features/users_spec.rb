require 'rails_helper'

describe '' do
  context 'as a guest' do
    it 'can see a register link' do
      visit root_path
      expect(page).to have_link 'Register'
    end

    it 'can register a new account' do
      register
      expect(current_path).to eq root_path
      expect(User.count).to eq 1
    end

    it 'cannot register without an email' do
      register(email: nil)
      expect(page).to have_content "Email can't be blank"
    end

    it 'cannot register with an email already registersed' do
      register
      click_on 'Logout'
      register
      expect(page).to have_content "Email has already been taken"
    end

    it 'cannot register with an invalid email address' do
      register(email: '^$%^%#$@#$^%$^.com')
      expect(page).to have_content "Email is invalid"
    end

    it 'cannot register without a password' do
      register(password: nil)
      expect(page).to have_content "Password can't be blank"
    end

    it 'cannot register without a password confirmation' do
      register(password_confirmation: nil)
      expect(page).to have_content "Password confirmation can't be blank"
    end

    it 'cannnot register when passwords do not match' do
      register(password: '123', password_confirmation: '1234')
      expect(page).to have_content "Password confirmation doesn't match Password"
    end

    it 'stays logged in after registration' do
      register
      expect(page).to have_link "Logout"
    end

    it 'gives me confirmation after successful registration' do
      register
      expect(page).to have_content "Registration successful, congrats you can use a keyboard."
    end

    it 'cannot backdoor to admin pages' do
      visit admin_items_path
      expect(current_path).to eq(login_path)
      visit admin_categories_path
      expect(current_path).to eq(login_path)
    end
  end

  context 'as a registered user' do

    let(:order) { Order.create(user_id: 1, order_type: 'pickup', address_id: 7, status: "ordered", total: 8000) }
    let(:user2) { User.create(first_name: "Nan", last_name: "Hass", email: "yourmommy@aol.com",
                  password: "password", password_confirmation: "password", role: :admin, nickname: "Nandozer") }

    let(:order2) { Order.create(user_id: user2.id, order_type: 'delivery', address_id: 7, status: "paid", total: 8000) }

    before(:each) do
      register(first_name: 'Nando', last_name: 'Hasselhoff', email: 'yourmom@aol.com', password: '123', password_confirmation: '123')
      login(email: 'yourmom@aol.com', password: '123')
      user2
      order
      order2
      visit root_path
    end

    it 'can view their orders' do
      click_on "My Orders"
      expect(page).to have_content "My Orders"
      expect(page).to have_content "pickup"
      expect(page).to have_content "ordered"
      expect(page).to have_link "Details"
    end

    it 'can not view other users orders' do
      click_on "My Orders"
      expect(page).to have_content "My Orders"
      expect(page).to_not have_content "delivery"
      expect(page).to_not have_content "paid"
    end

    it 'can view their user profile' do
      click_on "Nando's Info"
      expect(page).to have_content "Your Info"
    end

    it 'can link to a details page for each order' do
      click_on "My Orders"
      click_link 'Details'
      expect(current_path).to eq(order_path(order))
    end

    it 'can see all details of an individual order' do
      click_on "My Orders"
      click_link 'Details'
      expect(page).to have_content('Total:')
      expect(page).to have_content(order.format_date)
    end

    it 'can see updated order time when order is completed or cancelled' do
      click_on "My Orders"
      click_link "Details"
      click_on "Cancel"
      click_on "Details"
      expect(page).to_not have_link("Cancel")
      expect(page).to     have_content(order.format_updated_date)
      expect(page).to     have_content(order.format_updated_time)
    end

    it 'can view individual item details from an order' do
      item = Item.create( title: "Donut1", price: 2400,
                          description: "Good for one 'splorer.")
      order_item = OrderItem.create(item_id: item.id,
                                    order_id: order.id, quantity: 5, unit_price: 8000)

      click_on "My Orders"
      click_link "Details"
      click_link 'Donut1'
      expect(current_path).to eq(item_path(item))
      expect(page).to have_content(item.title)
      expect(page).to have_content(item.description)
    end
  end
end
