// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
import GalleryController from "./gallery_controller"
application.register("gallery", GalleryController)
import DropdownController from "./dropdown_controller"
application.register("dropdown", DropdownController)
import AvatarPreviewController from "./avatar_preview_controller"
application.register("avatar-preview", AvatarPreviewController)