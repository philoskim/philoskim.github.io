task :default => :html

doc_name = 'doc'

task :html do
  sh "scribble --htmls #{doc_name}.scrbl"
  if RUBY_PLATFORM == "i386-mswin32"
    sh "copy ..\\scribble.css #{doc_name}\\scribble.css"
    sh "copy ..\\scribble-original.css #{doc_name}\\scribble-original.css"
  else
    sh "cp -f ../scribble.css #{doc_name}/scribble.css"
    sh "cp -f ../scribble-original.css #{doc_name}/scribble-original.css"
    sh "cp -f ../manual-style.css #{doc_name}/manual-style.css"
  end
end

task :pdf do
  sh "scribble --latex #{doc_name}.scrbl"
  sh "ruby ../post_scribble.rb #{doc_name}.tex"
  sh "latex #{doc_name}.tex"
  # sh "dvipdfmx #{doc_name}.dvi"
  sh "rm -f *.aux *.log *.out"
end
