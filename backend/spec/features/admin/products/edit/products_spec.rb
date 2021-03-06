require 'spec_helper'

describe 'Product Details', type: :feature, js: true do
  stub_authorization!

  context 'editing a product with WYSIWYG disabled' do
    before do
      Spree::Config.product_wysiwyg_editor_enabled = false
      create(:product, name: 'Bún thịt nướng', sku: 'A100', description: 'lorem ipsum', available_on: '2013-08-14 01:02:03')
      visit spree.admin_products_path
      within_row(1) { click_icon :edit }
    end

    after { Spree::Config.product_wysiwyg_editor_enabled = true }

    it 'displays the product description as a standard input field' do
      expect(page).to have_field(id: 'product_description', with: 'lorem ipsum')
      expect(page).not_to have_css('#product_description_ifr')
    end
  end

  context 'editing a product with WYSIWYG editer enabled' do
    before do
      Spree::Config.product_wysiwyg_editor_enabled = true
      create(:product, name: 'Bún thịt nướng', sku: 'A100', description: 'lorem ipsum', available_on: '2013-08-14 01:02:03')
      visit spree.admin_products_path
      within_row(1) { click_icon :edit }
    end

    it 'displays the product details with a WYSIWYG editor for the product description input' do
      expect(page).to have_css('.content-header h1', text: 'Products / Bún thịt nướng')
      expect(page).to have_field(id: 'product_name', with: 'Bún thịt nướng')
      expect(page).to have_field(id: 'product_slug', with: 'bun-th-t-n-ng')
      expect(page).not_to have_field(id: 'product_description')
      expect(page).to have_css('#product_description_ifr')
      expect(page).to have_field(id: 'product_price', with: '19.99')
      expect(page).to have_field(id: 'product_cost_price', with: '17.00')
      expect(page).to have_field(id: 'product_available_on', type: :hidden, with: '2013-08-14')
      expect(page).to have_field(id: 'product_sku', with: 'A100')
    end

    it 'shows product description using wysiwyg editor' do
      expect(page).not_to have_field(id: 'product_description', with: 'lorem ipsum')
      expect(page).to have_css('#product_description_ifr')
    end

    it 'handles slug changes' do
      fill_in 'product_slug', with: 'random-slug-value'
      click_button 'Update'
      expect(page).to have_content('successfully updated!')
    end

    it 'has a link to preview a product' do
      allow(Spree::Core::Engine).to receive(:frontend_available?).and_return(true)
      allow_any_instance_of(ActionDispatch::Routing::RoutesProxy).to receive(:product_url).and_return('http://example.com/products/product-slug')
      click_link 'Details'
      expect(page).to have_css('#admin_preview_product')
      expect(page).to have_link Spree.t(:preview_product), href: 'http://example.com/products/product-slug'
    end
  end
end
