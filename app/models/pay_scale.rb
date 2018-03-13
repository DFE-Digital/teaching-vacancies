class PayScale < ApplicationRecord
  has_many :vacancies

  MPS = { "MPS": 22917,
          "MPS1": 22917,
          "MPS2": 24728,
          "MPS3": 26716,
          "MPS4": 28772,
          "MPS5": 31029,
          "MPS6": 33824 }.freeze

  UPS = { "UPS": 38633,
          "UPS1": 35927,
          "UPS2": 37258,
          "UPS3": 38633 }.freeze

  LPS = { "LPS": 39374,
          "LPS1": 40360,
          "LPS2": 41368,
          "LPS3": 42398,
          "LPS4": 43023,
          "LPS5": 44544,
          "LPS6": 45743,
          "LPS8": 46799,
          "LPS9": 47967,
          "LPS10": 49199,
          "LPS11": 50476,
          "LPS12": 51639,
          "LPS13": 52930,
          "LPS14": 54250,
          "LPS15": 55600,
          "LPS16": 57077,
          "LPS17": 58389,
          "LPS18": 59857 }.freeze
end
