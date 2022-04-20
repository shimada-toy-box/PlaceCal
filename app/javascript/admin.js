require("@rails/ujs").start()
require("turbolinks").start()

import "bootstrap"
import "./src/jquery"

// Input selectors
require("@nathanvda/cocoon")
require("select2")

// Datatables
import "./src/datatable.js"

// Opening times stuff
import  Vue from "vue"
import "vue-turbolinks"
import "./src/opening-times.js"

// Specific pages
import "./src/behaviors/all_behaviors.js"
import "./src/calendar-form.js"
import "./src/ward-picker.js"

$(document).on("turbolinks:load", function () {

  $("body").init_behaviors()

  $("[data-toggle='tooltip']").tooltip()
});
