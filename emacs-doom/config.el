;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;; Most basic I support for Brazil I could possibly do.
(projectile-register-project-type 'Brazil-Package '("Config")
                                  :compile "brazil-build")
(projectile-register-project-type 'Brazil-Workspace '("packageInfo"))
