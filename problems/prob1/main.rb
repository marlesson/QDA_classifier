# Classify Wine
# Marlesson
#

require '../../QDA_classifier'

# Read dataset

t_hits = {}
vezes  = 100
total  = 0
vezes.times do |t|
  
  t_hits[t] = 0
  dataset   = []

  File.open("wine.csv", "r").each_line do |line|
    features     = line.split(",")
    _features    = features.collect(&:to_f)
    _features[0] = features[0]
    dataset      << _features
  end

  # Separate dataset to train (70%) and predict (30%)
  dataset.shuffle!

  _dataset       = dataset.collect{|d| c = d[0]; d[0] = d[-1]; d[-1] = c; d} #change class and the last feature

  dataset_train = _dataset[0...(_dataset.size * 0.7)]
  dataset_pred  = _dataset[(_dataset.size * 0.7)..-1]

  # Classifier
  qda  = QDAClassifier.new(dataset_train, {normalization: :none})

  # Predicted values
  hit_classify = []
  dataset_pred.each do |feature_pred|
    classify     = qda.classify(feature_pred[0...-1])
    puts "#{t} - #{[classify, feature_pred.last].inspect} - #{(classify == feature_pred.last) ? 'OK' : '-' }"
    # Hit Classify
    hit_classify << feature_pred if(classify == feature_pred.last) 
  end

  t_hits[t] = (hit_classify.size.to_f/dataset_pred.size)
  total += t_hits[t]/vezes
end


fout = File.open("log_k.txt", "w")
t_hits.each do |k, val|
  log = "#{k}, #{val.to_f}"
  fout.puts log
  puts log
end

puts "Taxa de acerto total: #{total}"

