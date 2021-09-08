#!/usr/bin/env lisps

(bind-arguments
  (output-archive-path (error "output archive path missing")))


(let ((quicklisp-setup (read-from-string ($ "ensure-quicklisp"))))
  (load quicklisp-setup))


(ql:quickload '(:quickdist))


(with-temporary-directory (:pathname tmp-dist-dir)
  (let ((tmp-dist-dir (merge-pathnames "dist/" tmp-dist-dir)))
    (ensure-directories-exist tmp-dist-dir)
    (flet ((load-system (c)
             (ql:quickload (asdf::missing-requires c) :prompt nil)
             (quickdist:retry-loading-asd)))
      (handler-bind ((asdf:missing-dependency #'load-system)
                     (asdf:missing-component #'load-system))
        (quickdist:quickdist :name "alien-works"
                             :base-url "http://dist.borodust.org"
                             :projects-dir (uiop:pathname-directory-pathname *script-path*)
                             :dists-dir tmp-dist-dir))))
  (uiop:with-current-directory (tmp-dist-dir)
    ($ "tar" "-czf" output-archive-path "dist/")))
