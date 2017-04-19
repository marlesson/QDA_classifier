require '../../KNN_classifier'

# Read dataset

# Label

L_school    = {"GP" => 0, "MS" => 1}
L_sex       = {"F" => 0, "M" => 1}
L_address   = {"U" => 0, "R" => 1}
L_famsize   = {"LE3" => 0, "GT3" => 1}
L_pstatus   = {"T" => 0, "A" => 1}
L_mjob_fjob = {"teacher" => 0, "health" => 1, "services" => 2, "at_home" => 3, "other" => 4}
L_reason    = {"home" => 0, "reputation" => 1, "course" => 2, "other" => 3}
L_guardian  = {"mother" => 0, "father" => 1, "other" => 2}
L_yes_no    = {"yes" => 0, "no" => 1}
L_file      = {"student-mat.csv" => 0, "student-por.csv" => 1}

k_hits = {}
vezes  = 20


vezes.times do |t|
  dataset = []

  # school, sex, age, address, famsize, pstatus, medu, fedu, mjob,  fjob,  reason,  guardian,  traveltime,  studytime,  failures,  schoolsup,  famsup,  paid,  activities,  nursery,  higher,  internet,  romantic,  famrel,  freetime,  goout,  dalc,  walc,  health,  absences, 
  dataset = []

  ["student-mat.csv","student-por.csv"].each do |file|
    File.open(file, "r").each_line do |line|
      school, sex, age, address, famsize, pstatus, medu, fedu, mjob,  fjob,  reason,  
      guardian,  traveltime,  studytime,  failures,  schoolsup,  famsup,  paid,  activities,  
      nursery,  higher,  internet,  romantic,  famrel,  freetime,  goout,  dalc,  
      walc,  health,  absences, g1, g2, g3 = line.split(";").collect{|f| f.gsub("\"", "").strip}

      dataset << [L_school[school], L_sex[sex], age, L_address[address], L_famsize[famsize], L_pstatus[pstatus], medu, fedu, L_mjob_fjob[mjob],  L_mjob_fjob[fjob],  
                  L_reason[reason],  L_guardian[guardian],  traveltime,  studytime,  failures,  L_yes_no[schoolsup],  L_yes_no[famsup],  L_yes_no[paid],  
                  L_yes_no[activities],  L_yes_no[nursery],  L_yes_no[higher],  L_yes_no[internet],  L_yes_no[romantic],  famrel,  freetime,  
                  goout,  dalc,  health,  absences, L_file[file], g1, g2, g3, walc].collect(&:to_f)
    end
  end

  # Separate dataset to train (70%) and predict (30%)
  dataset.shuffle!

  #dataset       = dataset.collect{|d| c = d[0]; d[0] = d[-1]; d[-1] = c; d} #change class and the last feature

  dataset_train = dataset[0...(dataset.size * 0.7)]
  dataset_pred  = dataset[(dataset.size * 0.7)..-1]

  # Classifier

  knn  = KNNClassifier.new(dataset_train, {normalization: :standard_deviation})

  # # Predicted values
  # hit_classify = []
  # dataset_pred.each do |feature_pred|
  #   classify = knn.classify(feature_pred, 1)

  #   # Hit Classify
  #   hit_classify << feature_pred if(classify == feature_pred.last) 
  # end

  # puts "\n"
  # puts "Total Classify Predicted: #{dataset_pred.size}"
  # puts "Hit Classify Predicted: #{hit_classify.size} (#{(hit_classify.size.to_f/dataset_pred.size)*100}%)"

  # Predicted values
  k_times = (1..300)
  threads = []

  k_times.each do |k|
    next if (k%2 == 0)

    puts "#{t}, k: #{k}"
    
    k_hits[k] ||= 0;
    hit_classify = []
    dataset_pred.each do |feature_pred|
      classify = knn.classify(feature_pred, k)

      # Hit Classify
      hit_classify << feature_pred if(classify == feature_pred.last) 
    end

    k_hits[k] += (hit_classify.size.to_f/dataset_pred.size)/vezes
  end
end


fout = File.open("log_k.txt", "w")
k_hits.each do |k, val|
  log = "#{k}, #{val.to_f}"
  fout.puts log
  puts log
end

