namespace :data do
  namespace :update do
    desc 'Update payscale data'
    task pay_scale: :environment do
      PAYSCALE_DATA.each do |scale|
        roc = RegionalPayBandArea.find_by(name: 'Rest of England')
        payscale = PayScale.find_by(code: scale[0])
        payscale.update(regional_pay_band_area_id: roc.id)
      end
    end
  end
end

PAYSCALE_DATA = ['MPS1', 'MPS2', 'MPS3', 'MPS4', 'MPS5', 'MPS6', 'UPS1', 'UPS2', 'UPS3', 'LPS1', 'LPS2', 'LPS3',
                 'LPS4', 'LPS5', 'LPS6', 'LPS7', 'LPS8', 'LPS9', 'LPS10', 'LPS11', 'LPS12', 'LPS13', 'LPS14',
                 'LPS15', 'LPS16', 'LPS17', 'LPS18', 'LPS19', 'LPS20', 'LPS21', 'LPS22', 'LPS23', 'LPS24',
                 'LPS25', 'LPS26', 'LPS27', 'LPS28', 'LPS29', 'LPS30', 'LPS31', 'LPS32', 'LPS33', 'LPS34',
                 'LPS35', 'LPS36', 'LPS37', 'LPS38', 'LPS39', 'LPS40', 'LPS41', 'LPS42', 'LPS43'].freeze
