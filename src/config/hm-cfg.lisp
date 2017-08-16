;;; hm-cfg.lisp

;; Copyright (C) Thomas Dye 2016

;; Licensed under the Gnu Public License Version 3 or later

(in-package #:hm)

;; API
(defun fast-matrix-p (cfg)
  "Returns the boolean value for fast-matrix in the user's configuration, CFG."
  (get-option cfg "General configuration" "fast-matrix" :type :boolean))

(defun assume-correlations-p (cfg)
  "Returns the boolean value for assume-correlations in the user's
  configuration, CFG."
  (get-option cfg "General configuration" "assume-correlations" :type :boolean))

(defun input-file-name (cfg content)
  "Return the file name for CONTENT from the user's configuration, CFG. CONTENT
  is a string, one of `contexts', `observations', `inferences', `periods',
  `phases', `events', or `event-order'."
  (get-option cfg "Input files" content))

(defun input-file-name-p (cfg content)
  "Return a boolean indicating whether or not the user's configuration, CFG, includes a file name for CONTENT."
  (not (emptyp (get-option cfg "Input files" content))))

(defun file-header-p (cfg content)
  "Return the boolean value for CONTENT from the `Input file headers' section of
  the user's configuration, CFG."
  (get-option cfg "Input file headers" content :type :boolean))

(defun output-file-name (cfg content)
  "Return the file name for CONTENT from the user's configuration, CFG.  CONTENT is a string, one of `sequence-dot' or `chronology-dot'."
  (get-option cfg "Output files" content))

(defun missing-interfaces-p (cfg)
  "Return the boolean value of `add-missing-interfaces'."
  (get-option cfg "General configuration" "add-missing-interfaces" :type :boolean))

(defun graphviz-sequence-graph-attribute (cfg attribute)
  "Return the sequence graph attribute from the user's configuration, CFG."
  (get-option cfg "Graphviz sequence graph attributes" attribute))

(defun graphviz-node-classification (cfg attribute)
  "Return the value from the user's configuration, CFG, for the node ATTRIBUTE
classification. ATTRIBUTE is a string, one of `fill', `shape', `color',
`penwidth', `style', `polygon-distortion', `polygon-image',
`polygon-orientation', `plygon-sides', or `polygon-skew'."
  (let ((section "Graphviz sequence classification")
        (option (concatenate 'string "node-" attribute "-by")))
    (get-option cfg section option)))

(defun graphviz-edge-classification (cfg attribute)
  "Return the value from the user's configuration, CFG, for the edge ATTRIBUTE
  classification. ATTRIBUTE is a string, one of `color', `fontcolor',
  `penwidth', `style', or `classify'."
  (let ((section "Graphviz sequence classification")
        (option (concatenate 'string "edge-" attribute "-by")))
    (get-option cfg section option)))

(defun reachable-limit (cfg)
  "Return the numeric value of `reachable-limit' from the user's configuration,
CFG."
  (get-option cfg "Reachability configuration" "reachable-limit" :type :number))

(defun reachable-from-node (cfg)
  "Returns a symbol from the user's configuration, CFG."
  (symbolicate (get-option cfg "General configuration" "reachable-from")))

(defun chronology-graph-p (cfg)
  "Return a boolean value read from the user's configuration indicating whether
  or not to draw the chronology graph."
  (get-option cfg "Chronology graph" "draw" :type :boolean))

(defun include-url-p (cfg)
  "Return a boolean value read from the user's configuration, CFG, indicating whether or not to include an URL in the output."
  (get-option cfg "General configuration" "url-include" :type :boolean))

(defun default-url (cfg)
  "Return the default URL from the user's configuration, CFG, as a string"
  (get-option cfg "General configuration" "url-default"))

(defun user-color (cfg section option)
  "Given a user's configuration, CFG, a configuration file SECTION and OPTION,
  return a valid Graphviz color string, or the empty string if the user's CFG
  does not indicate a valid color string."
  (let ((color (get-option cfg section option))
        (scheme (get-option cfg section "colorscheme")))
    (if (and (not (emptyp color)) (not (emptyp scheme)))
        (graphviz-color-string color scheme) "")))

(defun sequence-classifier (cfg option)
  "Get the sequence classification, OPTION, from the user's configuration, CFG."
  (get-option cfg "Graphviz sequence classification" option))

;; API
(defun make-default-configuration ()
  "Returns the default configuration."
  (let ((cfg (make-config)))
    (add-section cfg "Output files")
    (set-option cfg "Output files" "sequence-dot" "")
    (set-option cfg "Output files" "chronology-dot" "")

    (add-section cfg "Input files")
    (set-option cfg "Input files" "contexts" "")
    (set-option cfg "Input files" "observations" "")
    (set-option cfg "Input files" "inferences" "")
    (set-option cfg "Input files" "periods" "")
    (set-option cfg "Input files" "phases" "")
    (set-option cfg "Input files" "events" "")
    (set-option cfg "Input files" "event-order" "")

    (add-section cfg "Input file headers")
    (set-option cfg "Input file headers" "contexts" "")
    (set-option cfg "Input file headers" "observations" "")
    (set-option cfg "Input file headers" "inferences" "")
    (set-option cfg "Input file headers" "periods" "")
    (set-option cfg "Input file headers" "phases" "")
    (set-option cfg "Input file headers" "events" "")
    (set-option cfg "Input file headers" "event-order" "")

    (add-section cfg "Chronology graph")
    (set-option cfg "Chronology graph" "draw" "off")

    (add-section cfg "General configuration")
    (set-option cfg "General configuration" "url-include" "off")
    (set-option cfg "General configuration" "url-default"
                "http://tsdye.github.io/harris-matrix/")
    (set-option cfg "General configuration" "legend" "off")
    (set-option cfg "General configuration" "assume-correlations" "no")
    (set-option cfg "General configuration" "fast-matrix" "on")
    (set-option cfg "General configuration" "add-missing-interfaces" "off")

    (add-section cfg "Graphviz sequence classification")
    ;; Node classifiers
    (set-option cfg "Graphviz sequence classification" "node-fill-by" "")
    (set-option cfg "Graphviz sequence classification" "node-shape-by" "units")
    (set-option cfg "Graphviz sequence classification" "node-color-by" "")
    (set-option cfg "Graphviz sequence classification" "node-penwidth-by" "")
    (set-option cfg "Graphviz sequence classification" "node-style-by" "")
    ;; Polygon classifiers
    (set-option cfg "Graphviz sequence classification"
                "node-polygon-distortion-by" "")
    (set-option cfg "Graphviz sequence classification"
                "node-polygon-image-by" "")
    (set-option cfg "Graphviz sequence classification"
                "node-polygon-orientation-by" "")
    (set-option cfg "Graphviz sequence classification"
                "node-polygon-sides-by" "")
    (set-option cfg "Graphviz sequence classification"
                "node-polygon-skew-by" "")
    ;; Edge classifiers
    (set-option cfg "Graphviz sequence classification" "edge-color-by" "")
    (set-option cfg "Graphviz sequence classification" "edge-fontcolor-by" "")
    (set-option cfg "Graphviz sequence classification" "edge-penwidth-by" "")
    (set-option cfg "Graphviz sequence classification" "edge-style-by" "")
    (set-option cfg "Graphviz sequence classification" "edge-classify-by" "from")

    (add-section cfg "Graphviz sequence graph attributes")
    (set-option cfg "Graphviz sequence graph attributes" "colorscheme" "x11")
    (set-option cfg "Graphviz sequence graph attributes" "bgcolor" "white")
    (set-option cfg "Graphviz sequence graph attributes" "fontname" "Times-Roman")
    (set-option cfg "Graphviz sequence graph attributes" "fontsize" "14.0")
    (set-option cfg "Graphviz sequence graph attributes" "fontcolor" "black")
    (set-option cfg "Graphviz sequence graph attributes" "label" "Sequence Diagram")
    (set-option cfg "Graphviz sequence graph attributes" "labelloc" "t")
    (set-option cfg "Graphviz sequence graph attributes" "style" "filled")
    (set-option cfg "Graphviz sequence graph attributes" "size" "")
    (set-option cfg "Graphviz sequence graph attributes" "ratio" "")
    (set-option cfg "Graphviz sequence graph attributes" "page" "")
    (set-option cfg "Graphviz sequence graph attributes" "dpi" "0.0")
    (set-option cfg "Graphviz sequence graph attributes" "margin" "")
    (set-option cfg "Graphviz sequence graph attributes" "label-break" "")
    (set-option cfg "Graphviz sequence graph attributes"
                "fontsize-subscript" "10.0")
    (set-option cfg "Graphviz sequence graph attributes" "splines" "ortho")

    (add-section cfg "Graphviz sequence edge attributes")
    (set-option cfg "Graphviz sequence edge attributes" "colorscheme" "x11")
    (set-option cfg "Graphviz sequence edge attributes" "style" "solid")
    (set-option cfg "Graphviz sequence edge attributes" "color" "black")
    (set-option cfg "Graphviz sequence edge attributes" "fontname" "Helvetica")
    (set-option cfg "Graphviz sequence edge attributes" "fontsize" "14.0")
    (set-option cfg "Graphviz sequence edge attributes" "fontcolor" "black")
    (set-option cfg "Graphviz sequence edge attributes" "arrowhead" "normal")
    (set-option cfg "Graphviz sequence edge attributes" "penwidth" "1.0")
    (set-option cfg "Graphviz sequence edge attributes" "penwidth-min" "1.0")
    (set-option cfg "Graphviz sequence edge attributes" "penwidth-max" "1.0")

    (add-section cfg "Graphviz sequence node attributes")
    (set-option cfg "Graphviz sequence node attributes" "shape" "box")
    (set-option cfg "Graphviz sequence node attributes" "colorscheme" "x11")
    (set-option cfg "Graphviz sequence node attributes" "style" "filled")
    (set-option cfg "Graphviz sequence node attributes" "color" "black")
    (set-option cfg "Graphviz sequence node attributes" "fontsize" "14.0")
    (set-option cfg "Graphviz sequence node attributes" "fontcolor" "black")
    (set-option cfg "Graphviz sequence node attributes" "fillcolor" "white")
    (set-option cfg "Graphviz sequence node attributes" "fontname" "Helvetica")
    (set-option cfg "Graphviz sequence node attributes" "penwidth" "1.0")
    (set-option cfg "Graphviz sequence node attributes" "penwidth-min" "1.0")
    (set-option cfg "Graphviz sequence node attributes" "penwidth-max" "1.0")

    ;;; Colorschemes
    (add-section cfg "Graphviz colorscheme")
    (set-option cfg "Graphviz colorscheme" "reachability" "")
    (set-option cfg "Graphviz colorscheme" "adjacency" "")
    (set-option cfg "Graphviz colorscheme" "units" "")
    (set-option cfg "Graphviz colorscheme" "distance" "")
    (set-option cfg "Graphviz colorscheme" "levels" "")
    (set-option cfg "Graphviz colorscheme" "periods" "")
    (set-option cfg "Graphviz colorscheme" "phases" "")

 ;;; Reachability configuration
    (add-section cfg "Reachability configuration")
    (set-option cfg "Reachability configuration" "reachable-from" "")
    (set-option cfg "Reachability configuration" "reachable-limit" "")

    ;; Reachability node colors
    (add-section cfg "Graphviz sequence reachability node colors")
    (set-option cfg "Graphviz sequence reachability node colors"
                "reachable" "grey25")
    (set-option cfg "Graphviz sequence reachability node colors"
                "not-reachable" "black")
    (set-option cfg "Graphviz sequence reachability node colors"
                "origin" "white")

    ;; Reachability node fills
    (add-section cfg "Graphviz sequence reachability node fillcolors")
    (set-option cfg "Graphviz sequence reachability node fillcolors"
                "reachable" "gray25")
    (set-option cfg "Graphviz sequence reachability node fillcolors"
                "not-reachable" "black")
    (set-option cfg "Graphviz sequence reachability node fillcolors"
                "origin" "white")

    ;; Reachability node shapes
    (add-section cfg "Graphviz sequence reachability node shapes")
    (set-option cfg "Graphviz sequence reachability node shapes"
                "reachable" "")
    (set-option cfg "Graphviz sequence reachability node shapes"
                "not-reachable" "")
    (set-option cfg "Graphviz sequence reachability node shapes"
                "origin" "")

    ;; Reachability node styles
    (add-section cfg "Graphviz sequence reachability node styles")
    (set-option cfg "Graphviz sequence reachability node styles"
                "reachable" "")
    (set-option cfg "Graphviz sequence reachability node styles"
                "not-reachable" "")
    (set-option cfg "Graphviz sequence reachability node styles"
                "origin" "")

    ;; Reachability node penwidths
    (add-section cfg "Graphviz sequence reachability node penwidths")
    (set-option cfg "Graphviz sequence reachability node penwidths"
                "reachable" "")
    (set-option cfg "Graphviz sequence reachability node penwidths"
                "not-reachable" "")
    (set-option cfg "Graphviz sequence reachability node penwidths"
                "origin" "")

    ;; Reachability edge penwidths
    (add-section cfg "Graphviz sequence reachability edge penwidths")
    (set-option cfg "Graphviz sequence reachability edge penwidths"
                "reachable" "")
    (set-option cfg "Graphviz sequence reachability edge penwidths"
                "not-reachable" "")
    (set-option cfg "Graphviz sequence reachability edge penwidths"
                "origin" "")

    ;; Reachability edge colors
    (add-section cfg "Graphviz sequence reachability edge colors")
    (set-option cfg "Graphviz sequence reachability edge colors"
                "reachable" "grey25")
    (set-option cfg "Graphviz sequence reachability edge colors"
                "not-reachable" "black")
    (set-option cfg "Graphviz sequence reachability edge colors"
                "origin" "white")

    ;; Reachability edge styles
    (add-section cfg "Graphviz sequence reachability edge styles")
    (set-option cfg "Graphviz sequence reachability edge styles"
                "reachable" "")
    (set-option cfg "Graphviz sequence reachability edge styles"
                "not-reachable" "")
    (set-option cfg "Graphviz sequence reachability edge styles"
                "origin" "")

    ;; Reachability edge fontcolors
    (add-section cfg "Graphviz sequence reachability edge fontcolors")
    (set-option cfg "Graphviz sequence reachability edge fontcolors"
                "reachable" "")
    (set-option cfg "Graphviz sequence reachability edge fontcolors"
                "not-reachable" "")
    (set-option cfg "Graphviz sequence reachability edge fontcolors"
                "origin" "")

    (add-section cfg "Adjacency configuration")
    (set-option cfg "Adjacency configuration" "origin" "")


    ;; Adjacent node colors
    (add-section cfg "Graphviz sequence adjacent node colors")
    (set-option cfg "Graphviz sequence adjacent node colors"
                "adjacent" "grey25")
    (set-option cfg "Graphviz sequence adjacent node colors"
                "not-adjacent" "black")
    (set-option cfg "Graphviz sequence adjacent node colors"
                "origin" "white")


    ;; Adjacent node fills
    (add-section cfg "Graphviz sequence adjacent node fillcolors")
    (set-option cfg "Graphviz sequence adjacent node fillcolors"
                "adjacent" "gray25")
    (set-option cfg "Graphviz sequence adjacent node fillcolors"
                "not-adjacent" "black")
    (set-option cfg "Graphviz sequence adjacent node fillcolors"
                "origin" "white")


    ;; Adjacent node shapes
    (add-section cfg "Graphviz sequence adjacent node shapes")
    (set-option cfg "Graphviz sequence adjacent node shapes"
                "adjacent" "")
    (set-option cfg "Graphviz sequence adjacent node shapes"
                "not-adjacent" "")
    (set-option cfg "Graphviz sequence adjacent node shapes"
                "origin" "")


    ;; Adjacent node styles
    (add-section cfg "Graphviz sequence adjacent node styles")
    (set-option cfg "Graphviz sequence adjacent node styles"
                "adjacent" "")
    (set-option cfg "Graphviz sequence adjacent node styles"
                "not-adjacent" "")
    (set-option cfg "Graphviz sequence adjacent node styles"
                "origin" "")


    ;; Adjacent node penwidths
    (add-section cfg "Graphviz sequence adjacent node penwidths")
    (set-option cfg "Graphviz sequence adjacent node penwidths"
                "adjacent" "")
    (set-option cfg "Graphviz sequence adjacent node penwidths"
                "not-adjacent" "")
    (set-option cfg "Graphviz sequence adjacent node penwidths"
                "origin" "")


    ;; Adjacent edge penwidths
    (add-section cfg "Graphviz sequence adjacent edge penwidths")
    (set-option cfg "Graphviz sequence adjacent edge penwidths"
                "adjacent" "")
    (set-option cfg "Graphviz sequence adjacent edge penwidths"
                "not-adjacent" "")
    (set-option cfg "Graphviz sequence adjacent edge penwidths"
                "origin" "")


    ;; Adjacent edge colors
    (add-section cfg "Graphviz sequence adjacent edge colors")
    (set-option cfg "Graphviz sequence adjacent edge colors"
                "adjacent" "grey25")
    (set-option cfg "Graphviz sequence adjacent edge colors"
                "not-adjacent" "black")
    (set-option cfg "Graphviz sequence adjacent edge colors"
                "origin" "white")


;; Adjacent edge styles
    (add-section cfg "Graphviz sequence adjacent edge styles")
    (set-option cfg "Graphviz sequence adjacent edge styles"
                "adjacent" "")
    (set-option cfg "Graphviz sequence adjacent edge styles"
                "not-adjacent" "")
    (set-option cfg "Graphviz sequence adjacent edge styles"
                "origin" "")


    ;; Adjacent edge fontcolors
    (add-section cfg "Graphviz sequence adjacent edge fontcolors")
    (set-option cfg "Graphviz sequence adjacent edge fontcolors"
                "adjacent" "")
    (set-option cfg "Graphviz sequence adjacent edge fontcolors"
                "not-adjacent" "")
    (set-option cfg "Graphviz sequence adjacent edge fontcolors"
                "origin" "")


    (add-section cfg "Graphviz sequence unit node attributes")
;; Unit nodes
    (set-option cfg "Graphviz sequence unit node attributes"
                "deposit-shape" "box")
    (set-option cfg "Graphviz sequence unit node attributes"
                "deposit-color" "black")
    (set-option cfg "Graphviz sequence unit node attributes"
                "deposit-fill" "white")
    (set-option cfg "Graphviz sequence unit node attributes"
                "deposit-penwidth" "")
    (set-option cfg "Graphviz sequence unit node attributes"
                "deposit-style" "filled")
    (set-option cfg "Graphviz sequence unit node attributes"
                "interface-shape" "trapezium")
    (set-option cfg "Graphviz sequence unit node attributes"
                "interface-fill" "white")
    (set-option cfg "Graphviz sequence unit node attributes"
                "interface-color" "black")
    (set-option cfg "Graphviz sequence unit node attributes"
                "interface-penwidth" "")
    (set-option cfg "Graphviz sequence unit node attributes"
                "interface-style" "")


    ;; Unit edges
    (add-section cfg "Graphviz sequence unit edge attributes")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "interface-color" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "interface-fontcolor" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "interface-penwidth" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "interface-style" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "deposit-color" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "deposit-fontcolor" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "deposit-penwidth" "")
    (set-option cfg "Graphviz sequence unit edge attributes"
                "deposit-style" "")

    (add-section cfg "Graphviz chronology graph attributes")
    (set-option cfg "Graphviz chronology graph attributes" "colorscheme" "x11")
    (set-option cfg "Graphviz chronology graph attributes" "fontname" "Times-Roman")
    (set-option cfg "Graphviz chronology graph attributes" "fontsize" "14.0")
    (set-option cfg "Graphviz chronology graph attributes" "fontcolor" "black")
    (set-option
     cfg "Graphviz chronology graph attributes" "label" "Chronology Graph")
    (set-option cfg "Graphviz chronology graph attributes" "labelloc" "t")
    (set-option cfg "Graphviz chronology graph attributes" "style" "filled")
    (set-option cfg "Graphviz chronology graph attributes" "size" "")
    (set-option cfg "Graphviz chronology graph attributes" "ratio" "")
    (set-option cfg "Graphviz chronology graph attributes" "page" "")
    (set-option cfg "Graphviz chronology graph attributes" "dpi" "0.0")
    (set-option cfg "Graphviz chronology graph attributes" "margin" "")
    (set-option cfg "Graphviz chronology graph attributes" "bgcolor" "white")
    (set-option cfg "Graphviz chronology graph attributes" "label-break" "")
    (set-option
     cfg "Graphviz chronology graph attributes" "fontsize-subscript" "10.0")
    (set-option cfg "Graphviz chronology graph attributes" "splines" "ortho")

    (add-section cfg "Graphviz chronology node attributes")
    (set-option cfg "Graphviz chronology node attributes" "style" "filled")
    (set-option cfg "Graphviz chronology node attributes" "fontname" "Times-Roman")
    (set-option cfg "Graphviz chronology node attributes" "fontsize" "14.0")
    (set-option cfg "Graphviz chronology node attributes" "fontcolor" "black")
    (set-option cfg "Graphviz chronology node attributes" "color" "black")
    (set-option cfg "Graphviz chronology node attributes" "fillcolor" "white")

    (add-section cfg "Graphviz chronology edge attributes")
    (set-option cfg "Graphviz chronology edge attributes" "fontname" "Times-Roman")
    (set-option cfg "Graphviz chronology edge attributes" "fontsize" "14.0")
    (set-option cfg "Graphviz chronology edge attributes" "fontcolor" "black")
    (set-option cfg "Graphviz chronology edge attributes" "arrowhead" "normal")
    (set-option cfg "Graphviz chronology edge attributes" "sequential" "solid")
    (set-option cfg "Graphviz chronology edge attributes" "abutting" "dashed")
    (set-option cfg "Graphviz chronology edge attributes" "separated" "dotted")
    (set-option cfg "Graphviz chronology edge attributes" "color" "black")

    (add-section cfg "Graphviz chronology node shapes")
    (set-option cfg "Graphviz chronology node shapes" "phase" "box")
    (set-option cfg "Graphviz chronology node shapes" "event" "ellipse")

    (add-section cfg "Graphviz colors")
    (set-option cfg "Graphviz colors" "color-label-dark" "black")
    (set-option cfg "Graphviz colors" "color-label-light" "white")

    (add-section cfg "Graphviz legend node attributes")
    (set-option cfg "Graphviz legend node attributes" "color" "black")
    (set-option cfg "Graphviz legend node attributes" "fillcolor" "white")
    (set-option cfg "Graphviz legend node attributes" "shape" "box")
    cfg))

(defun lookup-edge-option (cfg variable &optional domain option)
  "Given a user configuration, CFG, a string describing a user-set VARIABLE, and
optionally strings describing the DOMAIN and OPTION of the VARIABLE, return the
value of the edge option."
  (cond
    ((string= domain "units")
     (cond
       ((string= option "edge-color-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "deposit-color"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "interface-color"))))
       ((string= option "edge-fontcolor-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "deposit-fontcolor"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "interface-fontcolor"))))
       ((string= option "edge-penwidth-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "deposit-penwidth" :type :number))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "interface-penwidth"))))
       ((string= option "edge-style-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "deposit-style"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit edge attributes"
                       "interface-style"))))))
     ((string= domain "adjacent")
      (cond
        ((string= option "edge-penwidth-by")
         (cond
           ((string= variable "adjacent")
            (get-option cfg "Graphviz sequence reachability edge penwidths"
                        "reachable"))
           ((string= variable "origin")
            (get-option cfg "Graphviz sequence reachability edge penwidths"
                                   "origin"))
           ((string= variable "reachable")
            (get-option cfg "Graphviz sequence reachability edge penwidths"
                        "reachable"))
           ((string= variable "not-adjacent")
            (get-option cfg "Graphviz sequence reachability edge penwidths"
                        "not-reachable"))
           ))
        ((string= option "edge-color-by")
         (cond
           ((string= variable "adjacent")
            (get-option cfg "Graphviz sequence reachability edge colors"
                        "adjacent"))
           ((string= variable "origin")
            (get-option cfg "Graphviz sequence reachability edge colors"
                        "origin"))
           ((string= variable "reachable")
            (get-option cfg "Graphviz sequence reachability edge colors"
                        "reachable"))
           ((string= variable "not-adjacent")
            (get-option cfg "Graphviz sequence reachability edge colors"
                        "not-reachable"))))
        ((string= option "edge-style-by")
         (cond
           ((string= variable "adjacent")
            (get-option cfg "Graphviz sequence reachability edge styles"
                        "adjacent"))
           ((string= variable "origin")
            (get-option cfg "Graphviz sequence reachability edge styles"
                        "origin"))
           ((string= variable "reachable")
            (get-option cfg "Graphviz sequence reachability edge styles"
                        "reachable"))
           ((string= variable "not-adjacent")
            (get-option cfg "Graphviz sequence reachability edge styles"
                        "not-reachable"))))
        ((string= option "edge-fontcolor-by")
         (cond
           ((string= variable "adjacent")
            (get-option cfg "Graphviz sequence reachability edge fontcolors"
                        "adjacent"))
           ((string= variable "origin")
            (get-option cfg "Graphviz sequence reachability edge fontcolors"
                        "origin"))
           ((string= variable "reachable")
            (get-option cfg "Graphviz sequence reachability edge fontcolors"
                        "reachable"))
           ((string= variable "not-adjacent")
            (get-option cfg "Graphviz sequence reachability edge fontcolors"
                        "not-reachable"))))))
     ((not (and domain variable))
      (cond
        ((string= option "penwidth-max")
         (get-option cfg "Graphviz sequence edge attributes"
                     "penwidth-max"))
        ((string= option "penwidth-min")
         (get-option cfg "Graphviz sequence edge attributes"
                     "penwidth-min"))
        ((string= option "penwidth")
         (get-option cfg "Graphviz sequence edge attributes"
                     "penwidth"))
        ((string= option "arrowhead")
         (get-option cfg "Graphviz sequence edge attributes"
                     "arrowhead"))
        ((string= option "fontcolor")
         (get-option cfg "Graphviz sequence edge attributes"
                     "fontcolor"))
        ((string= option "fontsize")
         (get-option cfg "Graphviz sequence edge attributes"
                     "fontsize"))
        ((string= option "fontname")
         (get-option cfg "Graphviz sequence edge attributes"
                     "fontname"))
        ((string= option "color")
         (get-option cfg "Graphviz sequence edge attributes"
                     "color"))
        ((string= option "style")
         (get-option cfg "Graphviz sequence edge attributes"
                     "style"))
        ((string= option "colorscheme")
         (get-option cfg "Graphviz sequence edge attributes"
                     "colorscheme"))))))

(defun lookup-node-option (cfg variable &optional domain option)
  "Given a user configuration, CFG, a string describing a user-set VARIABLE, and
optionally strings describing the DOMAIN and OPTION of the VARIABLE, return the
value of the node option."
  (cond
    ((string= domain "units")
     (cond
       ((string= option "node-fill-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit attributes"
                       "deposit-node-fill"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit attributes"
                       "interface-node-fill"))))
       ((string= option "node-shape-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit attributes"
                       "deposit-node-shape"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit attributes"
                       "interface-node-shape"))))
       ((string= option "node-color-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit attributes"
                       "deposit-node-color"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit attributes"
                       "interface-node-color"))))
       ((string= option "node-penwidth-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit attributes"
                       "deposit-node-penwidth"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit attributes"
                       "interface-node-penwidth"))))
       ((string= option "node-style-by")
        (cond
          ((string= variable "deposit")
           (get-option cfg "Graphviz sequence unit attributes"
                       "deposit-node-style"))
          ((string= variable "interface")
           (get-option cfg "Graphviz sequence unit attributes"
                       "interface-node-style"))))))
  ((string= domain "adjacent")
   (cond
     ((string= option "node-fill-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-fill"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-fill"))
        ((string= variable "not-adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-fill"))))
     ((string= option "node-shape-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-shape"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-shape"))
        ((string= variable "not-adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-shape"))))
     ((string= option "node-color-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-color"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-color"))
        ((string= variable "not-adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-color"))))
     ((string= option "node-penwidth-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-penwidth"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-penwidth"))
        ((string= variable "not-adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-fill"))))
     ((string= option "node-style-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-style"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-style"))
        ((string= variable "not-adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-style"))))))
  ((string= domain "reachable")
   (cond
     ((string= option "node-fill-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-fill"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-fill"))
        ((string= variable "reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "reachable-node-fill"))
        ((string= variable "not-reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-fill"))))
     ((string= option "node-shape-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-shape"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-shape"))
        ((string= variable "reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "reachable-node-shape"))
        ((string= variable "not-reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-shape"))))
     ((string= option "node-color-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-color"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-color"))
        ((string= variable "not-reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-color"))))
     ((string= option "node-penwidth-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-penwidth"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-penwidth"))
        ((string= variable "reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "reachable-node-penwidth"))
        ((string= variable "not-reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-penwidth"))))
     ((string= option "node-style-by")
      (cond
        ((string= variable "origin")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "origin-node-style"))
        ((string= variable "adjacent")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "adjacent-node-style"))
        ((string= variable "reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "reachable-node-style"))
        ((string= variable "not-reachable")
         (get-option cfg "Graphviz sequence reachability attributes"
                     "not-reachable-node-style"))))
     ((not (and domain variable))
      (cond
        ((string= option "fillcolor")
         (get-option cfg "Graphviz sequence node attributes"
                     "fillcolor"))
        ((string= option "penwidth-max")
         (get-option cfg "Graphviz sequence node attributes"
                     "penwidth-max"))
        ((string= option "penwidth-min")
         (get-option cfg "Graphviz sequence node attributes"
                     "penwidth-min"))
        ((string= option "penwidth")
         (get-option cfg "Graphviz sequence node attributes"
                     "penwidth"))
        ((string= option "fontname")
         (get-option cfg "Graphviz sequence node attributes"
                     "fontname"))
        ((string= option "fontcolor")
         (get-option cfg "Graphviz sequence node attributes"
                     "fontcolor"))
        ((string= option "fontsize")
         (get-option cfg "Graphviz sequence node attributes"
                     "fontsize"))
        ((string= option "color")
         (get-option cfg "Graphviz sequence node attributes"
                     "color"))
        ((string= option "style")
         (get-option cfg "Graphviz sequence node attributes"
                     "style"))
        ((string= option "shape")
         (get-option cfg "Graphviz sequence node attributes"
                     "shape"))))))))

;; API
(defun write-default-configuration (path-name)
  "Write the default configuration to path-name."
  (let ((config (make-default-configuration)))
    (with-open-file (stream path-name :direction :output :if-exists :supersede)
      (write-stream config stream))))

;; API
(defun write-configuration (cfg path-name)
  "Write configuration, CFG, to the file, PATH-NAME."
  (with-open-file (stream path-name :direction :output :if-exists :supersede)
    (write-stream cfg stream)))

(defun Graphviz-section-p (section)
  "Given a section name string, SECTION, return true if the section
  contains options for Graphviz configuration.  Function depends on
  the convention of starting such sections with \"Graphviz\"."
  (eq 0 (search "Graphviz" section)))

;; API
(defun write-Graphviz-style-configuration (config path-name)
  "Write the Graphviz style portion of CONFIG to PATH-NAME."
  (let ((cfg (copy-structure config))
        (file-sections (sections config)))
    (dolist (section file-sections)
      (when (not (Graphviz-section-p section))
        (remove-section cfg section)))
    (write-configuration cfg path-name)))

;; API
(defun write-general-configuration (config path-name)
  "Write the non-Graphviz portion of CONFIG to PATH-NAME."
  (let ((cfg (copy-structure config))
        (file-sections (sections config)))
    (dolist (section file-sections)
      (when (Graphviz-section-p section)
        (remove-section cfg section)))
    (write-configuration cfg path-name)))

;; API
(defun convert-csv-config-to-ini (csv-file)
  "Augments the default configuration with the information in the csv
file, CSV-FILE, and returns a possibly modified configuration.  This
function can be used to convert the old style csv initialization files
to the new ini style."
  (let ((cfg (make-default-configuration))
        (ht (make-hash-table :test 'equal)))
    (cl-csv:read-csv csv-file
                     :map-fn #'(lambda (row)
                                 (setf (gethash (nth 0 row) ht) (nth 1 row))))

;    (add-section cfg "Output files")
    (set-option cfg "Output files" "sequence-dot"
                (gethash "*output-file-sequence*" ht))
    (set-option cfg "Output files" "chronology-dot"
                (gethash "*output-file-chronology*" ht))

;    (add-section cfg "Input files")
    (set-option cfg "Input files" "contexts"
                (gethash "*context-table-name*" ht))
    (set-option cfg "Input files" "observations"
                (gethash "*observation-table-name*" ht))
    (set-option cfg "Input files" "inferences"
                (gethash "*inference-table-name*" ht))
    (set-option cfg "Input files" "periods"
                (gethash "*period-table-name*" ht))
    (set-option cfg "Input files" "phases"
                (gethash "*phase-table-name*" ht))
    (set-option cfg "Input files" "events"
                (gethash "*radiocarbon-table-name*" ht))
    (set-option cfg "Input files" "event-order"
                (gethash "*date-order-table-name*" ht))

;    (add-section cfg "Input file headers")
    (set-option cfg "Input file headers" "contexts"
                (if (equal (gethash "*context-table-header*" ht) "t") "yes" "no"))
    (set-option cfg "Input file headers" "observations"
                (if (equal (gethash "*observation-table-header*" ht) "t")
                    "yes" "no"))
    (set-option cfg "Input file headers" "inferences"
                (if (equal (gethash "*inference-table-header*" ht) "t") "yes" "no"))
    (set-option cfg "Input file headers" "periods"
                (if (equal (gethash "*period-table-header*" ht) "t") "yes" "no"))
    (set-option cfg "Input file headers" "phases"
                (if (equal (gethash "*phase-table-header*" ht) "t") "yes" "no"))
    (set-option cfg "Input file headers" "events"
                (if (equal (gethash "*radiocarbon-table-header*" ht) "t")
                    "yes" "no"))
    (set-option cfg "Input file headers" "event-order"
                (if (equal (gethash "*date-order-table-header*" ht) "t")
                    "yes" "no"))

;    (add-section cfg "Chronology graph")
    (set-option cfg "Chronology graph" "draw"
                (if (equal (gethash "*create-chronology-graph*" ht) "t")
                    "on" "off"))

;    (add-section cfg "General configuration")
    (set-option cfg "General configuration" "reachable-from"
                (gethash "*reachable-from*" ht))
    (set-option cfg "General configuration" "reachable-limit"
                (gethash "*reachable-limit*" ht))
    (set-option cfg "General configuration" "url-include"
                (if (equal (gethash "*ulr-include*" ht) "nil") "off" "on"))
    (set-option cfg "General configuration" "url-default"
                (if (equal (gethash "*url-default*" ht) "nil") ""
                    (gethash "*url-default*" ht)))
    (set-option cfg "General configuration" "legend"
                (if (equal (gethash "*legend*" ht) "t") "on" "off"))
    (set-option cfg "General configuration" "assume-correlations"
                (if (equal (gethash "*assume-correlations-true*" ht) "t")
                    "yes" "no"))
    (set-option cfg "General configuration" "fast-matrix"
                (if (equal (gethash "*use-fast-matrix*" ht) "t") "on" "off"))

;    (add-section cfg "Graphviz sequence graph attributes")
    (set-option cfg "Graphviz sequence graph attributes" "colorscheme"
                (if (equal (gethash "*color-scheme-sequence*" ht) "nil") ""
                    (gethash "*color-scheme-sequence*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "bgcolor"
                (gethash "*color-fill-graph-sequence*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "fontname"
                (gethash "*font-name-graph-sequence*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "fontsize"
                (gethash "*font-size-graph-sequence*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "fontcolor"
                (gethash "*font-color-graph-sequence*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "label"
                (gethash "*graph-title-sequence*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "labelloc"
                (gethash "*graph-labelloc-sequence*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "style"
                (if (equal (gethash "*graph-style-sequence*" ht) "nil") ""
                    (gethash  "*graph-style-sequence*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "size"
                (if (equal (gethash "*graph-size-sequence*" ht) "nil") ""
                    (gethash  "*graph-size-sequence*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "ratio"
                (if (equal (gethash "*graph-ratio-sequence*" ht) "nil") ""
                    (gethash  "*graph-ratio-sequence*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "page"
                (if (equal (gethash "*graph-page-sequence*" ht) "nil") ""
                    (gethash  "*graph-page-sequence*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "dpi"
                (if (equal (gethash "*graph-dpi-sequence*" ht) "nil") ""
                    (gethash  "*graph-dpi-sequence*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "margin"
                (if (equal (gethash "*graph-margin-sequence*" ht) "nil") ""
                    (gethash  "*graph-margin-sequence*" ht)))
    ;; color-space???
    ;; (set-option cfg "Graphviz sequence graph attributes" "color-space"
    ;;             (gethash "*color-space*" ht))
    (set-option cfg "Graphviz sequence graph attributes" "label-break"
                (if (equal (gethash "*font-color-label-break*" ht) "nil") ""
                    (gethash "*font-color-label-break*" ht)))
    (set-option
     cfg "Graphviz sequence graph attributes" "fontsize-subscript"
     (if (or (not (gethash "*font-size-subscript*" ht))
             (equal (gethash "*font-size-subscript*" ht) "nil")) ""
             (gethash "*font-size-subscript*" ht)))
    (set-option cfg "Graphviz sequence graph attributes" "splines"
                (gethash "*graph-splines-sequence*" ht))

;    (add-section cfg "Graphviz sequence edge attributes")
    (set-option cfg "Graphviz sequence edge attributes" "style"
                (gethash "*style-edge-sequence*" ht))
    (set-option cfg "Graphviz sequence edge attributes" "color"
                (gethash "*color-edge-sequence*" ht))
    (set-option cfg "Graphviz sequence edge attributes" "fontname"
                (gethash "*font-name-edge-sequence*" ht))
    (set-option cfg "Graphviz sequence edge attributes" "fontsize"
                (gethash "*font-size-edge-sequence*" ht))
    (set-option cfg "Graphviz sequence edge attributes" "fontcolor"
                (gethash "*font-color-edge-sequence*" ht))
    (set-option cfg "Graphviz sequence edge attributes" "arrowhead"
                (gethash "*edge-arrowhead-sequence*" ht))
    (set-option cfg "Graphviz sequence edge attributes" "penwidth" "1.0")

;    (add-section cfg "Graphviz sequence node attributes")
    (set-option cfg "Graphviz sequence classification" "node-shape-by"
                (if (equal (gethash "*symbolize-unit-type*" ht) "t")
                    "units" ""))
    (set-option cfg "Graphviz sequence classification" "node-fill-by"
                (gethash "*node-fill-by*" ht))
    (set-option cfg "Graphviz sequence classification" "node-shape-by"
                (gethash "*node-shape-by*" ht))
    (set-option cfg "Graphviz sequence classification" "node-color-by"
                (gethash "*node-color-by*" ht))
    (set-option cfg "Graphviz sequence node attributes" "style"
                (gethash "*style-node-sequence*" ht))
    (set-option cfg "Graphviz sequence node attributes" "color"
                (gethash "*color-node-sequence*" ht))
    (set-option cfg "Graphviz sequence node attributes" "fontsize"
                (gethash "*font-size-node-sequence*" ht))
    (set-option cfg "Graphviz sequence node attributes" "fontcolor"
                (gethash "*font-color-node-sequence*" ht))
    (set-option cfg "Graphviz sequence node attributes" "fillcolor"
                (gethash "*color-fill-node-sequence*" ht))
    (set-option cfg "Graphviz sequence node attributes" "fontname"
                (gethash "*font-name-node-sequence*" ht))
    (set-option cfg "Graphviz sequence node attributes" "penwidth" "1.0")

;    (add-section cfg "Graphviz sequence reachability colors")
    (set-option cfg "Graphviz sequence reachability node colors"
                "reachable"
                (gethash "*color-reachable*" ht))
    (set-option cfg "Graphviz sequence reachability node colors"
                "not-reachable"
                (gethash "*color-not-reachable*" ht))
    (set-option cfg "Graphviz sequence reachability node colors"
                "origin"
                (gethash "*color-origin*" ht))
    (set-option cfg "Graphviz sequence reachability node colors"
                "adjacent"
                (gethash "*color-adjacent*" ht))

;    (add-section cfg "Graphviz sequence reachability shapes")
    (set-option cfg "Graphviz sequence reachability node shapes"
                "reachable"
                (if (equal (gethash "*shape-reachable*" ht) "nil") ""
                    (gethash "*shape-reachable*" ht)))
    (set-option cfg "Graphviz sequence reachability node shapes"
                "not-reachable"
                (if (equal (gethash "*shape-not-reachable*" ht) "nil") ""
                    (gethash "*shape-not-reachable*" ht)))
    (set-option cfg "Graphviz sequence reachability node shapes"
                "origin"
                (if (equal (gethash "*shape-origin*" ht) "nil") ""
                    (gethash "*shape-origin*" ht)))
    (set-option cfg "Graphviz sequence reachability node shapes"
                "adjacent"
                (if (equal (gethash "*shape-adjacent*" ht) "nil") ""
                    (gethash "*shape-adjacent*" ht)))

;; Graphviz sequence unit attributes
    (set-option cfg "Graphviz sequence unit attributes" "deposit-node-shape"
                (gethash "*shape-node-deposit*" ht))
    (set-option cfg "Graphviz sequence unit attributes"
                "deposit-node-color" "black")
    (set-option cfg "Graphviz sequence unit attributes" "deposit-node-fill"
                (gethash "*color-fill-node-deposit*" ht))
    (set-option cfg "Graphviz sequence unit attributes" "interface-node-shape"
                (gethash "*shape-node-interface*" ht))
    (set-option cfg "Graphviz sequence unit attributes"
                "interface-node-color" "black")
    (set-option cfg "Graphviz sequence unit attributes" "interface-node-fill"
                (gethash "*color-fill-node-interface*" ht))

;    (add-section cfg "Graphviz chronology graph attributes")
    (set-option cfg "Graphviz chronology graph attributes" "colorscheme"
                (if (equal (gethash "*color-scheme-chronology*" ht) "nil") ""
                    (gethash "*color-scheme-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "fontname"
                (if (equal (gethash "*font-name-graph-chronology*" ht) "nil") ""
                    (gethash "*font-name-graph-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "fontsize"
                (if (equal (gethash "*font-size-graph-chronology*" ht) "nil") ""
                    (gethash "*font-size-graph-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "fontcolor"
                (if (equal (gethash "*font-color-graph-chronology*" ht) "nil") ""
                    (gethash "*font-color-graph-chronology*" ht)))
    (set-option
     cfg "Graphviz chronology graph attributes" "label"
     (gethash "*graph-title-chronology*" ht))
    (set-option cfg "Graphviz chronology graph attributes" "labelloc"
                (gethash "*graph-labelloc-chronology*" ht))
    (set-option cfg "Graphviz chronology graph attributes" "style"
                (if (equal (gethash "*graph-style-chronology*" ht) "nil") ""
                    (gethash "*graph-style-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "size"
                (if (equal (gethash "*graph-size-chronology*" ht) "nil") ""
                    (gethash "*graph-size-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "ratio"
                (if (equal (gethash "*graph-ratio-chronology*" ht) "nil") ""
                    (gethash "*graph-ratio-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "page"
                (if (equal (gethash "*graph-page-chronology*" ht) "nil") ""
                    (gethash "*graph-page-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "dpi"
                (if (equal (gethash "*graph-dpi-chronology*" ht) "nil") ""
                    (gethash "*graph-dpi-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "margin"
                (if (equal (gethash "*graph-margin-chronology*" ht) "nil") ""
                    (gethash "*graph-margin-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "bgcolor"
                (if (equal (gethash "*color-fill-graph-chronology*" ht) "nil") ""
                    (gethash "*color-fill-graph-chronology*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "label-break"
                (if (equal (gethash "*font-color-label-break*" ht) "nil") ""
                    (gethash "*font-color-label-break*" ht)))
    (set-option
     cfg "Graphviz chronology graph attributes" "fontsize-subscript"
     (if (or (not (gethash "*font-size-subscript*" ht))
             (equal (gethash "*font-size-subscript*" ht) "nil")) ""
             (gethash "*font-size-subscript*" ht)))
    (set-option cfg "Graphviz chronology graph attributes" "splines"
                (gethash "*graph-splines-chronology*" ht))

;    (add-section cfg "Graphviz chronology node attributes")
    (set-option cfg "Graphviz chronology node attributes" "style"
                (gethash "*style-node-chronology*" ht))
    (set-option cfg "Graphviz chronology node attributes" "fontname"
                (gethash "*font-name-node-chronology*" ht))
    (set-option cfg "Graphviz chronology node attributes" "fontsize"
                (gethash "*font-size-node-chronology*" ht))
    (set-option cfg "Graphviz chronology node attributes" "fontcolor"
                (gethash "*font-color-node-chronology*" ht))
    (set-option cfg "Graphviz chronology node attributes" "color"
                (gethash "*color-node-chronology*" ht))
    (set-option cfg "Graphviz chronology node attributes" "fillcolor"
                (gethash "*color-fill-node-chronology*" ht))

;    (add-section cfg "Graphviz chronology edge attributes")
    (set-option cfg "Graphviz chronology edge attributes" "fontname"
                (gethash "*font-name-edge-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "fontsize"
                (gethash "*font-size-edge-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "fontcolor"
                (gethash "*font-color-edge-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "arrowhead"
                (gethash "*edge-arrowhead-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "sequential"
                (gethash "*edge-date-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "abutting"
                (gethash "*edge-abutting-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "separated"
                (gethash "*edge-separated-chronology*" ht))
    (set-option cfg "Graphviz chronology edge attributes" "color"
                (gethash "*color-edge-chronology*" ht))

;    (add-section cfg "Graphviz chronology node shapes")
    (set-option cfg "Graphviz chronology node shapes" "phase"
                (gethash "*shape-phase*" ht))
    (set-option cfg "Graphviz chronology node shapes" "event"
                (gethash "*shape-date*" ht))

;    (add-section cfg "Graphviz colors")
    (set-option cfg "Graphviz colors" "color-label-dark"
                (gethash "*color-label-dark*" ht))
    (set-option cfg "Graphviz colors" "color-label-light"
                (gethash "*color-label-light*" ht))

;    (add-section cfg "Graphviz legend node attributes")
    (set-option cfg "Graphviz legend node attributes" "color"
                (gethash "*color-node-legend*" ht))
    (set-option cfg "Graphviz legend node attributes" "fillcolor"
                (gethash "*color-fill-node-legend*" ht))
    (set-option cfg "Graphviz legend node attributes" "shape"
                (gethash "*shape-node-legend*" ht))
    cfg))

(defun Graphviz-node-fill-problem? (cfg)
  "If the user wants nodes filled by some graph function, then
  Graphviz requires that node-style-by be empty and the node style
  attribute be `filled'.  Returns nil if all is well, non-nil
  otherwise."
  (not
   (and (not (emptyp (get-option cfg "Graphviz sequence classification"
                                 "node-fill-by")))
        (emptyp (get-option cfg "Graphviz sequence classification"
                            "node-style-by"))
        (string= (get-option cfg "Graphviz sequence node attributes"
                             "style") "filled"))))

(defun Graphviz-node-polygon-shape-problem? (cfg)
  "Given a configuration, CFG, return nil if the user is set up to
  classify by manipulations of polygon node shape, non-nil otherwise"
  (and (not (or (emptyp (get-option cfg "Graphviz sequence classification"
                                    "node-polygon-distortion-by"))
                (emptyp (get-option cfg "Graphviz sequence classification"
                                    "node-polygon-image-by"))
                (emptyp (get-option cfg "Graphviz sequence classification"
                                    "node-polygon-orientation-by"))
                (emptyp (get-option cfg "Graphviz sequence classification"
                                    "node-polygon-sides-by"))
                (emptyp (get-option cfg "Graphviz sequence classification"
                                    "node-polygon-skew-by"))))
       (emptyp (get-option cfg "Graphviz sequence classification"
                           "node-shape-by"))
       (string= (get-option cfg "Graphviz sequence node attributes"
                            "shape") "polygon")))

(defun origin-node-missing? (cfg)
  "Returns non-nil if an origin node is needed by, but is missing from,
the configuration CFG, nil otherwise."
  (let ((options '("distance" "reachable" "adjacent")))
    (and (emptyp (get-option cfg "General configuration" "reachable-from"))
         (or
          (member (get-option cfg "Graphviz sequence classification"
                              "node-fill-by") options)
          (member (get-option cfg "Graphviz sequence classification"
                              "node-color-by") options)
          (member (get-option cfg "Graphviz sequence classification"
                              "node-shape-by") options)))))

(defun chronology-graph-restrictions-ignored? (cfg)
  "Returns non-nil if the configuration CFG ignores chronology graph
restrictions, nil otherwise."
  (and (get-option cfg "Chronology graph" "draw" :type :boolean)
       (get-option cfg "General configuration"
                   "assume-correlations" :type :boolean)))

(defun missing-contexts? (cfg)
  "Returns non-nil if contexts are missing from the configuration CFG,
nil otherwise."
  (let ((option (get-option cfg "Input files" "contexts")))
    (alexandria:emptyp option)))

(defun missing-observations? (cfg)
  "Returns non-nil if observations are missing from the configuration
CFG, nil otherwise."
  (let ((option (get-option cfg "Input files" "observations")))
    (alexandria:emptyp option)))

(defun unable-to-find-input-files? (cfg)
  "Returns non-nil if input files specified in the configuration CFG
can't be found, nil otherwise."
  (let ((option-list (options cfg "Input files"))
        (missing))
    (dolist (option option-list)
      (let ((file-name (get-option cfg "Input files" option)))
        (when file-name (unless (probe-file file-name) (push file-name missing)))))
    missing))

(defun reset-option (cfg section-name option-name value)
  "Ensure option names are not inadvertently created when setting an
option."
  (let ((section-list (sections cfg)))
    (assert (member section-name section-list :test #'equal)
            (section-name) "Error: \"~a\" is not one of ~a."
            section-name section-list))
  (let ((option-list (options cfg section-name)))
    (assert (member option-name option-list :test #'equal)
            (option-name) "Error: \"~a\" in not one of ~a."
            option-name option-list))
  (set-option cfg section-name option-name value))

(defun configuration-errors? (cfg)
  "Checks for problems in the configuration CFG, errors out if it
finds one, otherwise returns nil.  Problems include missing input
files, missing configuration values, and contradictory configuration
settings."
  (let ((missing-files (unable-to-find-input-files? cfg)))
    (when missing-files (error "Error: Unable to find ~a" missing-files)))
  (when (missing-contexts? cfg)
    (error "Error: Contexts file not specified."))
  (when (missing-observations? cfg)
    (error "Error: Observations file not specified."))
  (when (chronology-graph-restrictions-ignored? cfg)
    (error "Error: Cannot draw chronology graph when correlations assumed true."))
  (when (origin-node-missing? cfg)
    (error "Error: Origin node must be specified in \"reachable-from\"."))
  (when (Graphviz-node-fill-problem? cfg)
    (error "Error: Graphviz node fills are classified.  Check that \"node-style-by\" is not set and that node \"style\" is \"filled\"."))
  (when (Graphviz-node-polygon-shape-problem? cfg)
    (error "Error: Graphviz node polygons are classified.  Check that \"node-shape-by\" is not set and that node \"shape\" is \"polygon\".")))

(defun set-input-file (cfg option file-name header)
  "If the input file FILE-NAME exists and OPTION is recognized, then FILE-NAME
and HEADER are registered with the configuration, CFG."
  (let ((option-list (options cfg "Input files")))
    (assert (member option option-list :test #'equal)
            (option) "Error: \"~a\" is not one of ~a"
            option option-list)
    (if (probe-file file-name)
        (progn
          (set-option cfg "Input files" option file-name)
          (set-option cfg "Input file headers" option
                      (if header "yes" "no")))
        (error "Unable to find ~a." file-name))))

(defun set-dot-file (cfg option name &optional (verbose t))
  "Registers the chronology output file, NAME, with the OPTION in the
configuration CFG.  Checks if OPTION is known and errors out if not.
If NAME exists and VERBOSE is non-nil, then asks about overwriting it."
  (let ((option-list (options cfg "Output files")))
    (assert (member option option-list :test #'equal)
            (option) "Error: \"~a\" is not one of ~a"
            option option-list)
    (when (and (probe-file name) verbose)
      (unless (yes-or-no-p "Overwrite ~a?" name))
      (return-from set-dot-file))
    (set-option cfg "Output files" option name)))

(defun read-configuration-from-files (verbose &rest file-names)
  "Reads the initialization files FILE-NAMES and returns a configuration. Errors
out if one or more initialization files were not read. Prints a status message."
  (let ((config (make-default-configuration)))
    (dolist (file file-names)
      (when (null (probe-file file))
        (error "Error: unable to read file: ~s.~&" i)))
    (when verbose
      (format t "Read ~r initialization file~:p: ~{~a~^, ~}.~&"
              (length file-names) file-names))
    (dolist (file file-names)
      (read-files config (list file)))
    config))

(defun show-configuration-options (cfg section-name)
  "Print the options in section SECTION-NAME of configuration CFG.
Error out if CFG is not a configuration.  If SECTION-NAME isn't found
in CFG, then let the user try another SECTION-NAME."
  (unless (typep cfg 'config) (error "Error: ~a is not a configuration." cfg))
  (assert (has-section-p cfg section-name) (section-name)
          "Error: Unable to find ~a." section-name)
  (let ((key-val-list (items cfg section-name)))
    (dolist (pair key-val-list)
      (format t "~a = ~a~&" (car pair) (cdr pair)))))

(defun get-configuration-sections (cfg &optional (sort nil))
  "Return a list of sections in the configuration CFG, sorted alphabetically if
SORT is non-nil, or unsorted otherwise.  Assumes that CFG is a configuration."
  (let ((section-list (sections cfg)))
    (when sort (setf section-list (sort section-list #'string<)))
    section-list))

(defun show-configuration-sections (cfg &optional (sort t))
  "Print out the sections in configuration CFG, by default in sorted
order.  If SORT is nil, then print out the unsorted section list.
Errors out if CFG is not a configuration."
  (unless (typep cfg 'config) (error "Error: ~a is not a configuration." cfg))
  (let ((section-list (get-configuration-sections cfg sort)))
    (dolist (section section-list)
      (format t "~a~&" section))))

(defun get-all-configuration-options (cfg)
  "Return a list of the options in all sections of the configuration, CFG.  Assumest that CFG is a configuration."
  (let ((sections (get-configuration-sections cfg))
        (options nil))
    (dolist (section sections)
      (setf options (append options (items cfg section))))
    options))
