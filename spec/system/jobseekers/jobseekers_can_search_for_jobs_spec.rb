require "rails_helper"

RSpec.shared_examples "a successful search" do
  context "when searching for teacher jobs" do
    let(:keyword) { "Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("a", text: "Remove this filter Teacher")
    end

    it "displays page 1 jobs" do
      expect(page).to have_css(".search-results > .search-results__item", count: 2)
      expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 1, to: 2, total: 6, type: "results"))
    end

    context "when navigating between pages" do
      it "displays page 3 jobs" do
        within ".govuk-pagination" do
          click_on "3"
        end

        expect(page).to have_css(".search-results > .search-results__item", count: 2)
        expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 5, to: 6, total: 6, type: "results"))
      end
    end
  end

  context "when searching for maths jobs" do
    let(:per_page) { 100 }
    let(:keyword) { "Maths Teacher" }

    it "adds the expected filters" do
      expect(page).to have_css("a", text: "Remove this filter Teacher")
    end

    it "displays only the Maths jobs" do
      expect(page).to have_content strip_tags(I18n.t("app.pagy_stats_html", from: 1, to: 2, total: 2, type: "results"))
    end

    context "when sorting the jobs by most recently published" do
      it "displays the Maths jobs that were published most recently first" do
        expect("Maths 1").to appear_before("Maths Teacher 2")
      end
    end

    context "when clearing all applied filters" do
      before { click_on I18n.t("shared.filter_group.clear_all_filters") }

      it "displays no remove filter links" do
        expect(page).to_not have_css("a", text: "Remove this filter Teacher")
      end
    end

    context "when removing a filter" do
      before { click_on "Remove this filter Teacher" }

      it "removes the filter" do
        expect(page).to_not have_css("a", text: "Remove this filter Teacher")
      end
    end
  end
end

RSpec.describe "Jobseekers can search for jobs on the jobs index page" do
  let(:academy1) { create(:school, school_type: "Academies") }
  let(:academy2) { create(:school, school_type: "Academy") }
  let(:free_school1) { create(:school, school_type: "Free schools") }
  let(:free_school2) { create(:school, school_type: "Free school") }
  let(:local_authority_school1) { create(:school, school_type: "Local authority maintained schools") }
  let(:local_authority_school2) { create(:school, school_type: "Local authority maintained schools") }
  let(:school) { create(:school) }
  let!(:maths_job1) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], publish_on: Date.current - 1, job_title: "Maths 1", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary], expires_at: Date.current + 1, geolocation: "POINT(-0.019501 51.504949)") }
  let!(:maths_job2) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], publish_on: Date.current - 2, job_title: "Maths Teacher 2", subjects: %w[Mathematics], organisations: [school], phases: %w[secondary], expires_at: Date.current + 3, geolocation: "POINT(-1.8964 52.4820)") }
  let!(:job1) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], publish_on: Date.current - 3, job_title: "Physics Teacher", subjects: ["Physics"], organisations: [academy1], phases: %w[secondary], expires_at: Date.current + 2, geolocation: "POINT(-0.1273 51.4994)", visa_sponsorship_available: true) }
  let!(:job2) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], job_title: "PE Teacher", subjects: [], organisations: [academy2], expires_at: Date.current + 5) }
  let!(:job3) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], job_title: "Chemistry Teacher", subjects: [], organisations: [free_school1], expires_at: Date.current + 4, visa_sponsorship_available: true) }
  let!(:job4) { create(:vacancy, :past_publish, :no_tv_applications, job_roles: ["teacher"], job_title: "Geography Teacher", subjects: [], publisher_organisation: free_school1, organisations: [free_school1, free_school2], expires_at: Date.current + 6) }
  let!(:expired_job) { create(:vacancy, :expired, job_roles: ["teacher"], job_title: "Maths Teacher", subjects: [], organisations: [school]) }
  let(:per_page) { 2 }

  context "when searching using the mobile search fields" do
    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: per_page))
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "when searching using the desktop search field" do
    before do
      stub_const("Pagy::DEFAULT", Pagy::DEFAULT.merge(items: per_page))
      visit jobs_path
      fill_in "Keyword", with: keyword
      click_on I18n.t("buttons.search")
    end

    it_behaves_like "a successful search"
  end

  context "jobseekers can use the quick apply type filter to search for jobs" do
    let!(:quick_apply_job) { create(:vacancy, job_title: "Quick Apply Job", organisations: [school], enable_job_applications: true) }

    context "when quick apply is selected" do
      it "only shows vacancies that are quick apply" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.quick_apply")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([quick_apply_job])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
      end
    end
  end

  context "jobseekers can sort jobs by closing date" do
    it "lists the jobs with the earliest closing date first" do
      visit jobs_path
      select "Closing date", :from => "sort-by-field"
      click_button "Sort"
      expect(page).to have_select("sort_by", selected: "Closing date")
      expect("Maths 1").to appear_before("Physics Teacher")
      expect("Physics Teacher").to appear_before("Maths Teacher 2")
      expect("Maths Teacher 2").to appear_before("Chemistry Teacher")
      expect("Chemistry Teacher").to appear_before("PE Teacher")
      expect("PE Teacher").to appear_before("Geography Teacher")
    end
  end

  context "when jobseekers search without entering a location" do
    it "does not show any measure of distance" do
      visit jobs_path
      fill_in "Keyword", with: "teacher"
      click_on I18n.t("buttons.search")
      expect(page).not_to have_content "Distance from location"
    end
  end

  context "when jobseekers search after entering a location" do
    before do
      visit jobs_path
    end

    context "when jobseekers location an existing location polygon" do
      before do
        create(:location_polygon,
               name: "london",
               area: "POLYGON ((0.158291728375839 51.5119627532759, 0.127173319842768 51.519443883052, 0.096790065242576 51.515151184378, 0.0700073133548945 51.4992831652932, 0.0244415427050767 51.4983072825101,
               0.00922980001812057 51.5083136577337, -0.00895901937830904 51.5012892536481, -0.00322860475947555 51.4898311335115, -0.0153270178061662 51.4860247954694, -0.0261110081490698 51.4912591131507,
               -0.0298876779380238 51.5088633070019, -0.0610828806836839 51.5028680355528, -0.0791613314143606 51.5078185475811, -0.111548723934253 51.5107564648417, -0.124656697040582 51.494707869555, -0.13263868760487 51.4856986511178,
               -0.156078924734595 51.4846667296178, -0.173370959377855 51.4822659438249, -0.183856622834027 51.4774195514262, -0.189440802969997 51.4683570730225, -0.211150082862512 51.4697923243809, -0.228607126419863 51.4888033842042,
               -0.243717867655029 51.4884473004687, -0.260962503319067 51.4725603501939, -0.292732147657329 51.4874564779303, -0.322038659802479 51.470602703586, -0.321712316644831 51.4654065967685, -0.293999976672173 51.4854056656447,
               -0.26021508843963 51.4703135414066, -0.233208804578399 51.4885913069356, -0.222920593653172 51.4718579827518, -0.194109828651591 51.459841643393, -0.171606262733086 51.4802534436494, -0.126264661675309 51.4844792396574,
               -0.108900599208227 51.508442249132, -0.0688615530224064 51.4999142451471, -0.0334124364413469 51.5056572139623, -0.0323760915450547 51.4930264388859, -0.0226467117679587 51.4739856839454, -0.0183760542647176 51.4808479607712,
               -0.0178584020341604 51.4832186760532, 0.00198768339213075 51.4884607287772, 0.00274277834149525 51.5048831688193, 0.0216032626987668 51.4940154372677, 0.057805627199727 51.4940546169642, 0.0762345023564527 51.4958907050504,
               0.0920506502487 51.5090072164172, 0.120239031642939 51.5114451012857, 0.166826536954787 51.5032476495919, 0.177778272785473 51.4830664456915, 0.217626597355351 51.4804723183473, 0.202719272151978 51.4539320224287, 0.172854347003506 51.4432451859767,
               0.164326705343802 51.4285840881559, 0.155875039477239 51.4308765823689, 0.149311804229133 51.4091409564132, 0.1623841485646 51.3924903020708, 0.147534011717873 51.3921564371227, 0.152056317718389 51.3696937308686, 0.136958066672247 51.3441737072425,
               0.118456260553722 51.3441468837947, 0.117902452392139 51.3296623549062, 0.0850292985139502 51.3160232044164, 0.085816509713901 51.2931485605841, 0.0423964973902115 51.292673046743, 0.0329094179322316 51.3075209115003, 0.0150093376562001 51.2917851714264,
               0.00229468028240418 51.3291379508928, -0.0109946907963023 51.3335566824345, -0.0143280775371027 51.3298037619244, -0.02205674050425 51.3380987044597, -0.0379666402112328 51.3386427974036, -0.0502612211073994 51.3326393320776, -0.0513070799813812 51.3224478946691,
               -0.0788691314284766 51.3197737438307, -0.0911679398902129 51.3014725396081, -0.124294432311416 51.286757785019, -0.137313553947878 51.3007800058633, -0.155319119682667 51.3012744170214, -0.15654462281486 51.321507709494, -0.197372605139145 51.3435923839468,
               -0.220942517718077 51.3298621689165, -0.229781629922406 51.3365437600668, -0.217264427004088 51.3433870908451, -0.222863850097029 51.3571320560285, -0.245404876813987 51.3668445419862, -0.245031710905747 51.3800330880758, -0.261148595829857 51.3795989033006,
               -0.288130527717975 51.362264338488, -0.306193450322659 51.3350835335406, -0.330115430495874 51.3275172663916, -0.330510146404628 51.3484194351658, -0.307366865450373 51.3783835656421, -0.317699334676631 51.3936662018587, -0.32758694153077 51.3917439441589,
               -0.359140755031899 51.4119031812629, -0.390466012962148 51.4096434206027, -0.386641675185921 51.4200808186582, -0.392886205761403 51.4232834184323, -0.419078641810667 51.4323594356967, -0.439984797792763 51.4306264705421, -0.446288586536429 51.4399964193003,
               -0.456475092637393 51.4382245464136, -0.458641873967223 51.4563154428146, -0.509602428607785 51.4692733979147, -0.489977114250207 51.4948370082725, -0.483174001718439 51.5066468317737, -0.492331192305449 51.5170771807483, -0.495468374669196 51.5383345403589,
               -0.476597247361329 51.5580312037829, -0.49955682056323 51.5921834624787, -0.500595886737316 51.5996898995638, -0.499374812507721 51.6303779189848, -0.457132215188035 51.612293009053, -0.440504059697249 51.6200876669894, -0.404050204088779 51.6131830317757,
               -0.378511901963358 51.6177796723445, -0.362595599018668 51.6235359231513, -0.316673675005436 51.640535587181, -0.296127240762163 51.6354460666224, -0.25733412254289 51.6418309713103, -0.250582590956841 51.6560573513973, -0.212167514695587 51.6613369410502,
               -0.203352965649877 51.6701256003027, -0.19100826435175 51.6639480356733, -0.182085377518623 51.6686040576315, -0.172474630147304 51.6730904797185, -0.163494703411207 51.6881151011603, -0.118247464915559 51.6889369896988, -0.105779141322114 51.6918756442426,
               -0.0110655331484648 51.6808696794937, -0.0122597278478766 51.6462277976987, 0.0251577844733898 51.6372894134831, 0.0218175659827535 51.6288319121653, 0.0728322279658942 51.6046873837412, 0.0889219291168217 51.6048526721585, 0.0922848678893758 51.6135742637323,
               0.138182764130423 51.6235445244722, 0.200311529020805 51.6249348591335, 0.224086257092666 51.6317368900748, 0.252761923669615 51.6174464439055, 0.264560373974321 51.6083197922917, 0.254008655758463 51.6015973032368, 0.269877402345691 51.5995739217622,
               0.290289688724723 51.5642984939064, 0.313033607229797 51.5658172625212, 0.33402417092224 51.5405029063038, 0.26534727199935 51.5321502650812, 0.26368287909271 51.5178688945619, 0.253832892467226 51.5178858990023, 0.248963348105667 51.5286740570903,
               0.244904366445867 51.5187586037858, 0.237176008059422 51.5193344335382, 0.24201907475903 51.5079663102785, 0.226632969757395 51.5065860302677, 0.22996376255502 51.499365049628, 0.187593955309572 51.4879010539986, 0.1758975954326 51.5089631434707, 0.158291728375839 51.5119627532759))")
      end

      it "does not show distance measurements" do
        allow_any_instance_of(LocationSuggestion).to receive(:suggest_locations) { nil }
        fill_in "location-field", with: "London"
        click_on I18n.t("buttons.search")
        expect_page_to_show_jobs([maths_job1])
        expect(page).not_to have_content "Distance from location"
      end
    end

    context "when jobseekers location is a country" do
      it "does not show distance measurements" do
        fill_in "location-field", with: "England"
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([maths_job1, maths_job2, job1, job2, job3, job4])
        expect(page).not_to have_content "Distance from location"
      end
    end

    context "when jobseekers search is not a country or an existing location polygon" do
      before do
        allow_any_instance_of(LocationSuggestion).to receive(:suggest_locations) { nil }
        fill_in "location-field", with: "Birmingham"
        select "200 miles", from: "radius-field"
        click_on I18n.t("buttons.search")
      end

      it "shows distance between school and their location" do
        expect(page).to have_content "Jobs in or near Birmingham"

        within(".search-results__item", text: "Physics Teacher") do
          distance_text = find("dt", text: "Distance from location").sibling("dd").text
          expect(distance_text).to eq("76.6 miles")
        end

        within(".search-results__item", text: "Maths 1") do
          distance_text = find("dt", text: "Distance from location").sibling("dd").text
          expect(distance_text).to eq("81.2 miles")
        end

        within(".search-results__item", text: "Maths Teacher 2") do
          distance_text = find("dt", text: "Distance from location").sibling("dd").text
          expect(distance_text).to eq("90.1 miles")
        end
      end

      it "orders by distance by default" do
        expect(page).to have_select("sort_by", selected: "Distance")
        expect("Physics Teacher").to appear_before("Maths 1")
        expect("Maths 1").to appear_before("Maths Teacher 2")
      end

      it "jobseekers can then choose to sort by different sort option", js: true do
        expect(page).to have_select("sort_by", selected: "Distance")

        select "Closing date", :from => "sort-by-field"

        expect(page).to have_select("sort_by", selected: "Closing date")
        expect("Maths 1").to appear_before("Physics Teacher")
        expect("Physics Teacher").to appear_before("Maths Teacher 2")

        select "Newest job", :from => "sort-by-field"

        expect(page).to have_select("sort_by", selected: "Newest job")
        expect("Maths 1").to appear_before("Maths Teacher 2")
        expect("Maths Teacher 2").to appear_before("Physics Teacher")
      end
    end
  end

  context "jobseekers can use the visa sponsorship filter to search for jobs" do
    context "when visa sponsorship available is selected" do
      it "only shows jobs that offer visa sponsorship" do
        visit jobs_path
        check I18n.t("jobs.filters.visa_sponsorship_availability.option")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job3])
        expect_page_not_to_show_jobs([maths_job1, maths_job2, job2, job4])
      end
    end
  end

  context "jobseekers can use the organisation type filter to search for jobs" do
    let!(:job5) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "History Teacher", subjects: [], publisher_organisation: local_authority_school1, organisations: [local_authority_school1, local_authority_school2]) }

    context "when academy is selected" do
      it "only shows vacancies from academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job2, job3, job4])
        expect_page_not_to_show_jobs([maths_job1, maths_job2, job5])
      end
    end

    context "when local authority is selected" do
      it "only shows vacancies from local authorities" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job5])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
      end
    end

    context "when both local authority and academy are selected" do
      it "shows vacancies from both local authorities and academies" do
        visit jobs_path
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy")
        check I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority")
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1, job2, job3, job4, job5])
        expect_page_not_to_show_jobs([maths_job1, maths_job2])
      end
    end

    context "when used in conjunction with a search term" do
      # testing this unusual edge case around removing auto-populated search terms because it was raising exceptions for us in the past.
      it "returns the correct vacancies even after removing auto-populated search terms" do
        visit jobs_path
        fill_in "Keyword", with: "Physics teacher"
        check "Academy"

        click_on I18n.t("buttons.search")

        click_link "Remove this filter Teacher"
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([job1])
        expect_page_not_to_show_jobs([job2, job3, job4, job5, maths_job1, maths_job2])
      end
    end
  end

  context "when filtering by school type" do
    let(:special_school1) { create(:school, name: "Community special school", detailed_school_type: "Community special school") }
    let(:special_school2) { create(:school, name: "Foundation special school", detailed_school_type: "Foundation special school") }
    let(:special_school3) { create(:school, name: "Non-maintained special school", detailed_school_type: "Non-maintained special school") }
    let(:special_school4) { create(:school, name: "Academy special converter", detailed_school_type: "Academy special converter") }
    let(:special_school5) { create(:school, name: "Academy special sponsor led", detailed_school_type: "Academy special sponsor led") }
    let(:special_school6) { create(:school, name: "Non-maintained special school", detailed_school_type: "Free schools special") }
    let(:faith_school) { create(:school, name: "Religious", gias_data: { "ReligiousCharacter (name)" => "anything" }) }
    let(:faith_school2) { create(:school, name: "ABCDEF", gias_data: { "ReligiousCharacter (name)" => "somethingelse" }) }
    let(:non_faith_school1) { create(:school, name: "nonfaith1", gias_data: { "ReligiousCharacter (name)" => "" }) }
    let(:non_faith_school2) { create(:school, name: "nonfaith2", gias_data: { "ReligiousCharacter (name)" => "Does not apply" }) }
    let(:non_faith_school3) { create(:school, name: "nonfaith3", gias_data: { "ReligiousCharacter (name)" => "None" }) }

    let!(:special_job1) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "AAAA", subjects: [], organisations: [special_school1], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:special_job2) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "BBBB", subjects: [], organisations: [special_school2], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:special_job3) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "CCCC", subjects: [], organisations: [special_school3], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:special_job4) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "DDDD", subjects: [], organisations: [special_school4], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:special_job5) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "EEEE", subjects: [], organisations: [special_school5], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:special_job6) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "FFFF", subjects: [], organisations: [special_school6], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:faith_job) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "religious", subjects: ["Physics"], publisher_organisation: faith_school, organisations: [faith_school, faith_school2], phases: %w[secondary], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:non_faith_job1) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "nonfaith1", subjects: [], organisations: [non_faith_school1], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:non_faith_job2) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "nonfaith2", subjects: [], organisations: [non_faith_school2], geolocation: "POINT(-0.019501 51.504949)") }
    let!(:non_faith_job3) { create(:vacancy, :past_publish, job_roles: ["teacher"], job_title: "nonfaith3", subjects: [], organisations: [non_faith_school3], geolocation: "POINT(-0.019501 51.504949)") }

    it "allows user to filter by special schools" do
      visit jobs_path
      check I18n.t("organisations.filters.special_school")
      click_on I18n.t("buttons.search")

      expect_page_to_show_jobs([special_job1, special_job2, special_job3, special_job4, special_job5, special_job6])
      expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2, faith_job, non_faith_job1, non_faith_job2, non_faith_job3])
    end

    it "allows user to filter by faith schools" do
      visit jobs_path
      check I18n.t("organisations.filters.faith_school")
      click_on I18n.t("buttons.search")

      expect_page_to_show_jobs([faith_job])
      expect_page_not_to_show_jobs([special_job1, special_job2, special_job3, special_job4, special_job5, special_job6, job1, job2, job3, job4, maths_job1, maths_job2, non_faith_job1, non_faith_job2, non_faith_job3])
    end

    it "allows users to filter by both faith and special schools" do
      visit jobs_path
      check I18n.t("organisations.filters.faith_school")
      check I18n.t("organisations.filters.special_school")
      click_on I18n.t("buttons.search")

      expect_page_to_show_jobs([special_job1, special_job2, special_job3, special_job4, special_job5, special_job6, faith_job])
      expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2])
    end

    context "when used in conjunction with a search term" do
      # testing this unusual edge case around removing auto-populated search terms because it was raising exceptions for us in the past.
      it "returns the correct vacancies even after removing auto-populated search terms" do
        visit jobs_path
        fill_in "Keyword", with: "Physics teacher"
        fill_in "location-field", with: "Birmingham"
        select "200 miles", from: "radius-field"
        check I18n.t("organisations.filters.faith_school")

        click_on I18n.t("buttons.search")

        click_link "Remove this filter Teacher"
        click_on I18n.t("buttons.search")

        expect_page_to_show_jobs([faith_job])
        expect_page_not_to_show_jobs([job1, job2, job3, job4, maths_job1, maths_job2, special_job1, special_job2, special_job3, special_job4, special_job5, special_job6])
      end
    end
  end

  def expect_page_to_show_jobs(jobs)
    jobs.each do |job|
      expect(page).to have_link(job.job_title, count: 1)
    end
  end

  def expect_page_not_to_show_jobs(jobs)
    jobs.each do |job|
      expect(page).not_to have_link job.job_title
    end
  end
end
