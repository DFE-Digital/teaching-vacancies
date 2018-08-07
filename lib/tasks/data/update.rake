namespace :data do
  namespace :update do
    desc 'Update payscale data'
    task pay_scale: :environment do
      PAYSCALE_DATA.each_with_index do |scale, index|
        payscale = PayScale.find_by(code: scale[0])
        payscale.update(index: index, label: scale[1], starts_at: Date.new(2017, 9, 1)) if payscale.present?
      end
    end
  end
end

PAYSCALE_DATA = [['MPS1', 'Main pay range 1'],
                 ['MPS2', 'Main pay range 2'],
                 ['MPS3', 'Main pay range 3'],
                 ['MPS4', 'Main pay range 4'],
                 ['MPS5', 'Main pay range 5'],
                 ['MPS6', 'Main pay range 6'],
                 ['UPS1', 'Upper pay range 1'],
                 ['UPS2', 'Upper pay range 2'],
                 ['UPS3', 'Upper pay range 3'],
                 ['LPS1', 'Lead Practitioners range 1'],
                 ['LPS2', 'Lead Practitioners range 2'],
                 ['LPS3', 'Lead Practitioners range 3'],
                 ['LPS4', 'Lead Practitioners range 4'],
                 ['LPS5', 'Lead Practitioners range 5'],
                 ['LPS6', 'Lead Practitioners range 6'],
                 ['LPS7', 'Lead Practitioners range 7'],
                 ['LPS8', 'Lead Practitioners range 8'],
                 ['LPS9', 'Lead Practitioners range 9'],
                 ['LPS10', 'Lead Practitioners range 10'],
                 ['LPS11', 'Lead Practitioners range 11'],
                 ['LPS12', 'Lead Practitioners range 12'],
                 ['LPS13', 'Lead Practitioners range 13'],
                 ['LPS14', 'Lead Practitioners range 14'],
                 ['LPS15', 'Lead Practitioners range 15'],
                 ['LPS16', 'Lead Practitioners range 16'],
                 ['LPS17', 'Lead Practitioners range 17'],
                 ['LPS18', 'Lead Practitioners range 18'],
                 ['LPS19', 'Lead Practitioners range 19'],
                 ['LPS20', 'Lead Practitioners range 20'],
                 ['LPS21', 'Lead Practitioners range 21'],
                 ['LPS22', 'Lead Practitioners range 22'],
                 ['LPS23', 'Lead Practitioners range 23'],
                 ['LPS24', 'Lead Practitioners range 24'],
                 ['LPS25', 'Lead Practitioners range 25'],
                 ['LPS26', 'Lead Practitioners range 26'],
                 ['LPS27', 'Lead Practitioners range 27'],
                 ['LPS28', 'Lead Practitioners range 28'],
                 ['LPS29', 'Lead Practitioners range 29'],
                 ['LPS30', 'Lead Practitioners range 30'],
                 ['LPS31', 'Lead Practitioners range 31'],
                 ['LPS32', 'Lead Practitioners range 32'],
                 ['LPS33', 'Lead Practitioners range 33'],
                 ['LPS34', 'Lead Practitioners range 34'],
                 ['LPS35', 'Lead Practitioners range 35'],
                 ['LPS36', 'Lead Practitioners range 36'],
                 ['LPS37', 'Lead Practitioners range 37'],
                 ['LPS38', 'Lead Practitioners range 38'],
                 ['LPS39', 'Lead Practitioners range 39'],
                 ['LPS40', 'Lead Practitioners range 40'],
                 ['LPS41', 'Lead Practitioners range 41'],
                 ['LPS42', 'Lead Practitioners range 42'],
                 ['LPS43', 'Lead Practitioners range 43']].freeze
