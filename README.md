
# ISSR-TODO app: a dynamic todo-app without a line of JavaScript

[http://cjackson.tk/todo-tutorial](http://cjackson.tk/todo-tutorial)

Overview: https://github.com/interactive-ssr/client/blob/master/main.org

> What makes ISSR unique is its lack of any kind of client-side programming. Other Server based frameworks allow you write what would normally be written in Javascript onto the server. ISSR goes a step further into the land of declarative programming by moving any interactive changes into the realm of HTML generation (rather than DOM manipulation). The web developer only needs to know HTML and the server-side programming language (and CSS if you want styles); No knowledge about Javascript or DOM is necessary.

load issr-test.asd (C-c C-k)

(ql:quickload "issr-test")

Access http://localhost:8080/products


See also: https://github.com/dbohdan/liveviews