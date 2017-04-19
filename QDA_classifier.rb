#used for mean, standard deviation, etc.
require 'descriptive_statistics'
require 'matrix'

class QDAClassifier

  attr_reader :dataset, :dataset_normalized, :classes, :matrix_conv

  MIN  = 0
  MAX  = 1
  MEAN = 2
  SD   = 3 
  VAR  = 4
  SUM  = 5

  # dataset = [
  #     [feature1, feature2, feature3, ..., featureN, "class1"],
  #     [feature1, feature2, feature3, ..., featureN, "class2"],
  #     [feature1, feature2, feature3, ..., featureN, "class2"],
  #   ]
  def initialize(dataset = [], options = {})
    @dataset            = dataset
    @dataset_normalized = []
    @matrix_conv        = {}
    @normalization      = options[:normalization] || :linear # linear or standard_deviation

    set_classes
    normalize
    build_matrix_conv
  end


  # This method classify the features, and return de class
  def classify(features)
    # # Order by probability
    feature_normalized = get_features_normalized(features)
    
    res = @classes.sort_by do |klasse|
      discriminating(klasse, feature_normalized)
    end.first

    res
  end  

  def count_features
    @dataset.first.size - 1
  end

  def count_classes
    @classes.size
  end

  # {klass => [[min, max, mean, sd, var, sum]], [min, max, mean, sd, var, sum]... [min, max, mean, sd, var, sum]}
  def statistics_of_features_by_class
    sta = {}

    @classes.each do |klasse|
      sta[klasse] = get_statistics_of_features(klasse)
    end

    sta
  end

  def mean_features_by_class
    return @mean_features_by_class if !@mean_features_by_class.nil?

    @mean_features_by_class   = {}
    statistic                 = statistics_of_features_by_class

    @classes.each do |klasse|
      @mean_features_by_class[klasse] = []
    
      count_features.times do |fi|
        @mean_features_by_class[klasse][fi] = statistic[klasse][fi][MEAN]
      end
    end

    @mean_features_by_class
  end

  # {klass => [
  #   [var1, var2.. varn]
  #   [var1, var2.. varn]
  #   [var1, var2.. varn]
  # ]
  def build_matrix_conv
    @matrix_conv  = {}
    mean          = mean_features_by_class

    @classes.each do |klasse|
      matrix      = []
      data_klasse = @dataset_normalized.select{|d| d[-1] == klasse}
      
      count_features.times do |i|
        matrix[i] = []
        
        count_features.times do |k|
          conv_ik = 0

          data_klasse.each do |d|
            conv_ik += (d[i] - mean[klasse][i])*(d[k] - mean[klasse][k])
          end

          matrix[i][k] = (conv_ik.to_f)/(data_klasse.size)
        end
      end

      @matrix_conv[klasse] = Matrix::rows matrix
    end 

    @matrix_conv
  end

  private 

  def discriminating(klasse, features)
    conv_matrix   = @matrix_conv[klasse]
    mean_features = Matrix[mean_features_by_class[klasse]]
    features      = Matrix[features]

    result        = (Math::log(conv_matrix.det)+((features-mean_features)*conv_matrix.inverse*(features-mean_features).transpose)[0,0])/count_classes
  end

  def set_classes
    @classes = @dataset.collect{|d| d.last}.uniq.sort
  end

  # Normalize dataset 
  def normalize()
    @dataset.each do |features|
      feature_normalized = get_features_normalized(features)
      # Add class
      feature_normalized[count_features] = features.last

      @dataset_normalized << feature_normalized
    end
  end

  def get_features_normalized(features)
    case @normalization
      when :linear
        normalize_linear(features)
      when :standard_deviation
        normalize_sd(features)
      when :none
        features
      else
        raise "Normalization not found"
      end
  end
  
  # Normalize dataset with a Normalization by Linear
  def normalize_linear(features)
    # [min, max, mean, sd]
    statistics = get_statistics_of_features
    n_features = []

    count_features.times do |fi|
      min, max, mean, sd = statistics[fi]
      n_features[fi] = (features[fi]-min).to_f/(max-min)
    end

    n_features
  end

  # Normalize dataset with a Normalization by standard deviation 
  def normalize_sd(features)
    # [min, max, mean, sd]
    statistics = get_statistics_of_features
    n_features = []
    
    count_features.times do |fi|
      min, max, mean, sd = statistics[fi]
      n_features[fi] = (features[fi]-mean).to_f/(sd)
    end

    n_features
  end

  # Return the statistics of all features (min, max, mean, sd, var, sum)
  def get_statistics_of_features(klass = nil)
    # Statistics of features (min, max, mean, sd, var, sum)
    @statistics  = []

    count_features.times do |i|
      f_min, f_max, f_mean, f_std, f_var, f_sum = statistics_of_features(i, klass)

      @statistics[i] = [f_min, f_max, f_mean, f_std, f_var, f_sum]
    end

    @statistics
  end

  # Return the statistics of feature (min, max, mean, sd, var, sum)
  def statistics_of_features(index, klass = nil)

    if klass.nil?
      features_of_class = @dataset.collect{|d| d[index]}
    else
      features_of_class = @dataset.select{|d| d[-1] == klass}.collect{|d| d[index]}
    end

    #statistical properties of the feature set
    f_std  = features_of_class.standard_deviation
    f_mean = features_of_class.mean
    f_min  = features_of_class.min
    f_max  = features_of_class.max
    f_var  = features_of_class.variance    
    f_sum  = features_of_class.sum

    return [f_min, f_max, f_mean, f_std, f_var, f_sum]
  end
end


# qda = QDAClassifier.new([
#       [feature1, feature2, feature3, ..., featureN, "class2"],
#       [feature1, feature2, feature3, ..., featureN, "class2"]
#     ])
# 
# qda.classify([feature1, feature2, feature3, ..., featureN])
#