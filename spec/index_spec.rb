#
# Index page
#

require_relative 'spec_helper'

feature 'index' do
  it "should show an index page" do
    visit '/2015-02-18/'

    # header
    expect(page).to have_selector '.navbar-fixed-top.blank .navbar-brand', 
      text: '2015-02-18'
    expect(page).to have_selector '.navbar-fixed-top .label-danger a', 
      text: '2'
    expect(page).to have_selector '#agenda', text: 'Agenda'

    # navigation
    expect(page).to have_selector 'a[href=Change-Geronimo-Chair]',
      text: 'Special Orders'

    # rows with colors and titles
    expect(page).to have_selector 'tr.missing td', text: 'Abdera'
    expect(page).to have_selector 'tr.rejected td', text: 'Axis'
    expect(page).to have_selector 'tr.commented td', text: 'Buildr'
    expect(page).to have_selector 'tr.reviewed td', text: 'Celix'

    # attach, owner, shepherd columns
    expect(page).to have_selector 'tr.reviewed td', text: 'CF'
    expect(page).to have_selector 'tr.reviewed td', text: 'Mark Cox'
    expect(page).to have_selector 'tr.missing td', text: 'Sam'
    expect(page).to have_selector 'tr[10] td[2]', text: 'Executive Assistant'
    expect(page).to have_selector 'tr[10] td[4]', text: 'Ross'

    # links
    expect(page).to have_selector 'a[href=ACE]', text: 'ACE'

    # footer
    expect(page).to have_selector '.backlink[href="../2015-01-21/"]', 
     text: '2015-01-21'
    expect(page).to have_selector 'button', text: 'refresh'
    expect(page).to have_selector 'button', text: 'add resolution'
    expect(page).to have_selector '.nextlink[href="help"]', text: 'Help'

    # hidden form
    expect(page).to have_selector '.modal .modal-dialog .modal-header h4',
      text: 'Add Resolution'
  end
end
