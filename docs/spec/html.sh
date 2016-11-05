asciidoctor -a stylesheet=my-asciidoctor.css spec-memo.adoc doc/*.adoc
mv spec-memo.html index.html

#asciidoctor clojure-complete-html.adoc **/*.adoc
#mv clojure-complete-html.html index.html
