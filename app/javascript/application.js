// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import * as bootstrap from "bootstrap"
window.bootstrap = bootstrap

import "trix"
import "@rails/actiontext"

import "./controllers"
