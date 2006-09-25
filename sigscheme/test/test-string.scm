;;  Filename : test-string.scm
;;  About    : unit test for R5RS string
;;
;;  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
;;
;;  All rights reserved.
;;
;;  Redistribution and use in source and binary forms, with or without
;;  modification, are permitted provided that the following conditions
;;  are met:
;;
;;  1. Redistributions of source code must retain the above copyright
;;     notice, this list of conditions and the following disclaimer.
;;  2. Redistributions in binary form must reproduce the above copyright
;;     notice, this list of conditions and the following disclaimer in the
;;     documentation and/or other materials provided with the distribution.
;;  3. Neither the name of authors nor the names of its contributors
;;     may be used to endorse or promote products derived from this software
;;     without specific prior written permission.
;;
;;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
;;  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
;;  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;;  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
;;  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
;;  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
;;  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
;;  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
;;  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
;;  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
;;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

(load "./test/unittest.scm")

(define tn test-name)

;;
;; All procedures which take the string as argument is tested with
;; both immutable string and mutable string.
;;
;; See "3.4 Storage model" of R5RS
;;


;; check string?
;;;; immutable
(assert-true "string? immutable" (string? ""))
(assert-true "string? immutable" (string? "abcde"))
(assert-true "string? immutable" (string? (symbol->string 'foo)))
;;;; mutable
(assert-true "string? mutable" (string? (string-copy "")))
(assert-true "string? mutable" (string? (string-copy "abcde")))


;; check make-string
(assert-equal? "make-string check" ""   (make-string 0))
(assert-equal? "make-string check" " "  (make-string 1))
(assert-equal? "make-string check" "  " (make-string 2))
(assert-equal? "make-string check" ""   (make-string 0 #\a))
(assert-equal? "make-string check" "a"  (make-string 1 #\a))
(assert-equal? "make-string check" "aa" (make-string 2 #\a))


;; check string-ref
;;;; immutable
(assert-equal? "string-ref immutable" #\a (string-ref "abcde" 0))
(assert-equal? "string-ref immutable" #\e (string-ref "abcde" 4))
(assert-error  "string-ref immutable" (lambda ()
					(string-ref "abcde" -1)))
(assert-error  "string-ref immutable" (lambda ()
					(string-ref "abcde" 5)))
;;;; mutable
(assert-equal? "string-ref mutable" #\a (string-ref (string-copy "abcde") 0))
(assert-equal? "string-ref mutable" #\e (string-ref (string-copy "abcde") 4))
(assert-error  "string-ref mutable" (lambda ()
				      (string-ref (string-copy "abcde") -1)))
(assert-error  "string-ref mutable" (lambda ()
				      (string-ref (string-copy "abcde") 5)))


;; check string-set!
;;;; immutable
(assert-error "string-set! immutable" (lambda ()
					(string-set! "foo" 0 #\b)))
(assert-error "string-set! immutable" (lambda ()
					(string-set! (symbol->string 'foo) 0 #\b)))
(assert-error "string-set! immutable" (lambda ()
					(define immutable-str "foo")
					(string-set! immutable-str 0 #\b)
					immutable-str))
;;;; mutable
(assert-equal? "string-set! mutable" "zbcdef"
	       (begin
		 (define tmpstr (string-copy "abcdef"))
		 (string-set! tmpstr 0 #\z)
		 tmpstr))
(assert-equal? "string-set! mutable" "abzdef"
	       (begin
		 (define tmpstr (string-copy "abcdef"))
		 (string-set! tmpstr 2 #\z)
		 tmpstr))
(assert-equal? "string-set! mutable" "abcdez"
	       (begin
		 (define tmpstr (string-copy "abcdef"))
		 (string-set! tmpstr 5 #\z)
		 tmpstr))
(assert-error  "string-set! mutable" (lambda ()
				       (string-set! (string-copy "abcdef") -1 #\z)))
(assert-error  "string-set! mutable" (lambda ()
				       (string-set! (string-copy "abcdef")  6 #\z)))


;; check string-length
;;;; immutable
(assert-equal? "string-length immutable" 0 (string-length ""))
(assert-equal? "string-length immutable" 5 (string-length "abcde"))
(assert-equal? "string-length immutable" 1 (string-length "\\"))
(assert-equal? "string-length immutable" 2 (string-length "\\\\"))
(assert-equal? "string-length immutable" 3 (string-length "\\\\\\"))
;;;; mutable
(assert-equal? "string-length mutable" 0 (string-length (string-copy "")))
(assert-equal? "string-length mutable" 5 (string-length (string-copy "abcde")))
(assert-equal? "string-length mutable" 1 (string-length (string-copy "\\")))
(assert-equal? "string-length mutable" 2 (string-length (string-copy "\\\\")))
(assert-equal? "string-length mutable" 3 (string-length (string-copy "\\\\\\")))


;; string=? check
;;;; immutable
(assert-true "string=? immutable" (string=? "" ""))
(assert-true "string=? immutable" (string=? "abcde" "abcde"))
(assert-true "string=? immutable" (string=? "foo" "foo"))
(assert-true "string=? immutable" (string=? "foo" (symbol->string 'foo)))
(assert-true "string=? immutable" (string=? (symbol->string 'foo) "foo"))
(assert-true "string=? immutable" (string=? (symbol->string 'foo) (symbol->string 'foo)))
;;;; mutable
(assert-true "string=? mutable" (string=? (string-copy "") (string-copy "")))
(assert-true "string=? mutable" (string=? (string-copy "foo") (string-copy "foo")))
;;;; mixed
(assert-true "string=? mixed" (string=? (string-copy "") ""))
(assert-true "string=? mixed" (string=? (string-copy "foo") "foo"))
(assert-true "string=? mixed" (string=? (string-copy "foo") (symbol->string 'foo)))


;; substring check
;;;; immutable
(tn "substring immutable")
(assert-error  (tn) (lambda () (substring "foo" 0 -1)))
(assert-equal? (tn) ""    (substring "foo" 0 0))
(assert-equal? (tn) "f"   (substring "foo" 0 1))
(assert-equal? (tn) "fo"  (substring "foo" 0 2))
(assert-equal? (tn) "foo" (substring "foo" 0 3))
(assert-error  (tn) (lambda () (substring "foo" 0 4)))
(assert-error  (tn) (lambda () (substring "foo" -1 0)))
(assert-error  (tn) (lambda () (substring "foo" 1 0)))
(assert-equal? (tn) "oo"  (substring "foo" 1 3))
(assert-equal? (tn) "o"   (substring "foo" 2 3))
(assert-equal? (tn) ""    (substring "foo" 3 3))
(assert-error  (tn) (lambda () (substring "foo" 4 3)))
(assert-error  (tn) (lambda () (substring "foo" 4 4)))
(assert-equal? (tn) "foo" (substring (symbol->string 'foo) 0 3))
;;;; mutable
(assert-equal? "substring mutable" ""    (substring (string-copy "abcde") 0 0))
(assert-equal? "substring mutable" "a"   (substring (string-copy "abcde") 0 1))
(assert-equal? "substring mutable" "bc"  (substring (string-copy "abcde") 1 3))
(assert-equal? "substring mutable" "bcd" (substring (string-copy "abcde") 1 4))
(assert-error  "substring mutable" (lambda ()
				     (substring (string-copy "abcde") 1 -1)))
(assert-error  "substring mutable" (lambda ()
				     (substring (string-copy "abcde") -1 1)))
(assert-error  "substring mutable" (lambda ()
				     (substring (string-copy "abcde") -1 -1)))
(assert-error  "substring mutable" (lambda ()
				     (substring (string-copy "abcde") 2 1)))


;; string-append check
;;;; immutable
(assert-equal? "string-append immutable" ""       (string-append ""))
(assert-equal? "string-append immutable" ""       (string-append "" ""))
(assert-equal? "string-append immutable" ""       (string-append "" "" ""))
(assert-equal? "string-append immutable" "a"      (string-append "a"))
(assert-equal? "string-append immutable" "ab"     (string-append "a" "b"))
(assert-equal? "string-append immutable" "abc"    (string-append "a" "b" "c"))
(assert-equal? "string-append immutable" "ab"     (string-append "ab"))
(assert-equal? "string-append immutable" "abcd"   (string-append "ab" "cd"))
(assert-equal? "string-append immutable" "abcdef" (string-append "ab" "cd" "ef"))
;;;; mutable
(assert-equal? "string-append mutable" ""       (string-append (string-copy "")))
(assert-equal? "string-append mutable" ""       (string-append (string-copy "") (string-copy "")))
(assert-equal? "string-append mutable" ""       (string-append (string-copy "") (string-copy "") (string-copy "")))
(assert-equal? "string-append mutable" "a"      (string-append (string-copy "a")))
(assert-equal? "string-append mutable" "ab"     (string-append (string-copy "a") (string-copy "b")))
(assert-equal? "string-append mutable" "abc"    (string-append (string-copy "a") (string-copy "b") (string-copy "c")))
(assert-equal? "string-append mutable" "ab"     (string-append (string-copy "ab")))
(assert-equal? "string-append mutable" "abcd"   (string-append (string-copy "ab") (string-copy "cd")))
(assert-equal? "string-append mutable" "abcdef" (string-append (string-copy "ab") (string-copy "cd") (string-copy "ef")))
;;; mixed
(assert-equal? "string-append mixed" ""    (string-append (string-copy "") ""))
(assert-equal? "string-append mixed" "ab"  (string-append (string-copy "a") "b"))
(assert-equal? "string-append mixed" "abc" (string-append "a" (string-copy "b") (string-copy "c")))
(assert-equal? "string-append mixed" "abc" (string-append (string-copy "a") "b" (string-copy "c")))
(assert-equal? "string-append mixed" "abc" (string-append (string-copy "a") (string-copy "b") "c"))
(assert-equal? "string-append mixed" "abc" (string-append "a" "b" (string-copy "c")))
(assert-equal? "string-append mixed" "abc" (string-append "a" (string-copy "b") "c"))
(assert-equal? "string-append mixed" "abc" (string-append (string-copy "a") "b" "c"))


;; string->list
;;;; immutable
(assert-equal? "string->list immutable" '()                (string->list ""))
(assert-equal? "string->list immutable" '(#\\)             (string->list "\\"))
(assert-equal? "string->list immutable" '(#\\ #\\)         (string->list "\\\\"))
(assert-equal? "string->list immutable" '(#\\ #\\ #\\)     (string->list "\\\\\\"))
;;(assert-equal? "string->list immutable" '(#\tab)           (string->list "\t"))
(assert-equal? "string->list immutable" '(#\	)      (string->list "\t"))
;;(assert-equal? "string->list immutable" '(#\return)        (string->list "\r"))
(assert-equal? "string->list immutable" '(#\
(assert-equal? "string->list immutable" '(#\
(assert-equal? "string->list immutable" '(#\newline)           (string->list "\n"))
(assert-equal? "string->list immutable" '(#\newline #\newline) (string->list "\n\n"))
(assert-equal? "string->list immutable" '(#\space)         (string->list " "))
(assert-equal? "string->list immutable" '(#\space #\space) (string->list "  "))
(assert-equal? "string->list immutable" '(#\")             (string->list "\""))
(assert-equal? "string->list immutable" '(#\" #\")         (string->list "\"\""))
;;;; mutable
(assert-equal? "string->list mutable" '()                    (string->list (string-copy "")))
(assert-equal? "string->list mutable" '(#\\)                 (string->list (string-copy "\\")))
(assert-equal? "string->list mutable" '(#\\ #\\)             (string->list (string-copy "\\\\")))
(assert-equal? "string->list mutable" '(#\\ #\\ #\\)         (string->list (string-copy "\\\\\\")))
;;(assert-equal? "string->list mutable" '(#\tab)           (string->list (string-copy "\t")))
(assert-equal? "string->list mutable" '(#\	)            (string->list (string-copy "\t")))
;;(assert-equal? "string->list mutable" '(#\return)        (string->list (string-copy "\r")))
(assert-equal? "string->list mutable" '(#\
(assert-equal? "string->list mutable" '(#\
(assert-equal? "string->list mutable" '(#\newline)           (string->list (string-copy "\n")))
(assert-equal? "string->list mutable" '(#\newline #\newline) (string->list (string-copy "\n\n")))
(assert-equal? "string->list mutable" '(#\space)             (string->list (string-copy " ")))
(assert-equal? "string->list mutable" '(#\space #\space)     (string->list (string-copy "  ")))
(assert-equal? "string->list mutable" '(#\")                 (string->list (string-copy "\"")))
(assert-equal? "string->list mutable" '(#\" #\")             (string->list (string-copy "\"\"")))

;; list->string
(assert-equal? "list->string check" ""     (list->string '()))
(assert-equal? "list->string check" "\\"     (list->string '(#\\)))
(assert-equal? "list->string check" "\\\\"   (list->string '(#\\ #\\)))
(assert-equal? "list->string check" "\\\\\\" (list->string '(#\\ #\\ #\\)))
(assert-equal? "list->string check" "\t" (list->string '(#\	)))
;;(assert-equal? "list->string check" "\t" (list->string '(#\tab)))
(assert-equal? "list->string check" "\r" (list->string '(#\
;;(assert-equal? "list->string check" "\r" (list->string '(#\return)))
(assert-equal? "list->string check" "\n" (list->string '(#\
)))
(assert-equal? "list->string check" "\n" (list->string '(#\newline)))
(assert-equal? "list->string check" " " (list->string '(#\ )))
(assert-equal? "list->string check" " " (list->string '(#\space)))
(assert-equal? "list->string check" " " (list->string '(#\ )))
(assert-equal? "list->string check" "\"" (list->string '(#\")))
(assert-equal? "list->string check" "\"a\"" (list->string '(#\" #\a #\")))

;; string-fill!
;;;; immutable
(assert-error "string-fill! immutable" (lambda ()
					 (string-fill! "" #\j)))
(assert-error "string-fill! immutable" (lambda ()
					 (string-fill! "foo" #\j)))
(assert-error "string-fill! immutable" (lambda ()
					 (string-fill! (string->symbol 'foo) #\j)))
;;;; mutable
(assert-equal? "string-fill! mutable" "" (begin
					   (define tmpstr (string-copy ""))
					   (string-fill! tmpstr #\j)
					   tmpstr))
(assert-equal? "string-fill! mutable" "jjjjj" (begin
						(define tmpstr (string-copy "abcde"))
						(string-fill! tmpstr #\j)
						tmpstr))
(assert-equal? "string-fill! mutable" "\\\\\\" (begin
						 (define tmpstr (string-copy "abc"))
						 (string-fill! tmpstr #\\)
						 tmpstr))

;; string-copy
(assert-equal? "string copy check" ""   (string-copy ""))
(assert-equal? "string copy check" "a"  (string-copy "a"))
(assert-equal? "string copy check" "ab" (string-copy "ab"))

;; symbol->string
(assert-equal? "symbol->string check" "a"  (symbol->string 'a))
(assert-equal? "symbol->string check" "ab" (symbol->string 'ab))

;; string->symbol
;; TODO: need to investigate (string->symbol "") behavior
;;;; immutable
(assert-equal? "string->symbol immutable" 'a  (string->symbol "a"))
(assert-equal? "string->symbol immutable" 'ab (string->symbol "ab"))
;;;; mutable
(assert-equal? "string->symbol mutable" 'a  (string->symbol (string-copy "a")))
(assert-equal? "string->symbol mutable" 'ab (string->symbol (string-copy "ab")))

;;
;; escape sequences
;;

(define integer->string
  (lambda (i)
    (list->string (list (integer->char i)))))

;; R5RS compliant
(assert-equal? "R5RS escape sequence" (integer->string 34)        "\"")  ;; 34
(assert-equal? "R5RS escape sequence" (list->string '(#\"))       "\"")  ;; 34
(assert-equal? "R5RS escape sequence" '(#\")       (string->list "\""))  ;; 34
(assert-equal? "R5RS escape sequence" (integer->string 92)        "\\")  ;; 92
(assert-equal? "R5RS escape sequence" (list->string '(#\\))       "\\")  ;; 92
(assert-equal? "R5RS escape sequence" '(#\\)       (string->list "\\"))  ;; 92
(assert-equal? "R5RS escape sequence" (integer->string 10)        "\n")  ;; 110
(assert-equal? "R5RS escape sequence" (list->string '(#\newline)) "\n")  ;; 110
(assert-equal? "R5RS escape sequence" '(#\newline) (string->list "\n"))  ;; 110

;; R6RS(SRFI-75) compliant
(tn "R6RS escape sequence")
(assert-equal? (tn) (integer->string 0)         "\x00")  ;; 0
(assert-equal? (tn) (list->string '(#\nul))     "\x00")  ;; 0
(assert-equal? (tn) '(#\nul)  (string->list    "\x00"))  ;; 0
(assert-equal? (tn) (integer->string 7)           "\a")  ;; 97
(assert-equal? (tn) (list->string '(#\alarm))     "\a")  ;; 97
(assert-equal? (tn) '(#\alarm)  (string->list    "\a"))  ;; 97
(assert-equal? (tn) (integer->string 8)           "\b")  ;; 98
(assert-equal? (tn) (list->string '(#\backspace)) "\b")  ;; 98
(assert-equal? (tn) '(#\backspace) (string->list "\b"))  ;; 98
(assert-equal? (tn) (integer->string 12)          "\f")  ;; 102
(assert-equal? (tn) (list->string '(#\page))      "\f")  ;; 102
(assert-equal? (tn) '(#\page)   (string->list    "\f"))  ;; 102
(assert-equal? (tn) (integer->string 13)          "\r")  ;; 114
(assert-equal? (tn) (list->string '(#\return))    "\r")  ;; 114
(assert-equal? (tn) '(#\return) (string->list    "\r"))  ;; 114
(assert-equal? (tn) (integer->string 9)           "\t")  ;; 116
(assert-equal? (tn) (list->string '(#\tab))       "\t")  ;; 116
(assert-equal? (tn) '(#\tab)    (string->list    "\t"))  ;; 116
(assert-equal? (tn) (integer->string 11)          "\v")  ;; 118
(assert-equal? (tn) (list->string '(#\vtab))      "\v")  ;; 118
(assert-equal? (tn) '(#\vtab)   (string->list    "\v"))  ;; 118
(assert-equal? (tn) (integer->string 124)         "\|")  ;; 124

;; All these conventional escape sequences should cause parse error as defined
;; in SRFI-75: "Any other character in a string after a backslash is an
;; error".
;;                                                      "\0"   ;; 0
(assert-parse-error "conventional escape sequence" "\"\\ \"")  ;; 32
(assert-parse-error "conventional escape sequence" "\"\\!\"")  ;; 33
;;                                                      "\""   ;; 34
(assert-parse-error "conventional escape sequence" "\"\\#\"")  ;; 35
(assert-parse-error "conventional escape sequence" "\"\\$\"")  ;; 36
(assert-parse-error "conventional escape sequence" "\"\\%\"")  ;; 37
(assert-parse-error "conventional escape sequence" "\"\\&\"")  ;; 38
(assert-parse-error "conventional escape sequence" "\"\\'\"")  ;; 39
(assert-parse-error "conventional escape sequence" "\"\\(\"")  ;; 40
(assert-parse-error "conventional escape sequence" "\"\\)\"")  ;; 41
(assert-parse-error "conventional escape sequence" "\"\\*\"")  ;; 42
(assert-parse-error "conventional escape sequence" "\"\\+\"")  ;; 43
(assert-parse-error "conventional escape sequence" "\"\\,\"")  ;; 44
(assert-parse-error "conventional escape sequence" "\"\\-\"")  ;; 45
(assert-parse-error "conventional escape sequence" "\"\\.\"")  ;; 46
(assert-parse-error "conventional escape sequence" "\"\\/\"")  ;; 47
(assert-parse-error "conventional escape sequence" "\"\\0\"")  ;; 48
(assert-parse-error "conventional escape sequence" "\"\\1\"")  ;; 49
(assert-parse-error "conventional escape sequence" "\"\\2\"")  ;; 50
(assert-parse-error "conventional escape sequence" "\"\\3\"")  ;; 51
(assert-parse-error "conventional escape sequence" "\"\\4\"")  ;; 52
(assert-parse-error "conventional escape sequence" "\"\\5\"")  ;; 53
(assert-parse-error "conventional escape sequence" "\"\\6\"")  ;; 54
(assert-parse-error "conventional escape sequence" "\"\\7\"")  ;; 55
(assert-parse-error "conventional escape sequence" "\"\\8\"")  ;; 56
(assert-parse-error "conventional escape sequence" "\"\\9\"")  ;; 57
(assert-parse-error "conventional escape sequence" "\"\\:\"")  ;; 58
(assert-parse-error "conventional escape sequence" "\"\\;\"")  ;; 59
(assert-parse-error "conventional escape sequence" "\"\\<\"")  ;; 60
(assert-parse-error "conventional escape sequence" "\"\\=\"")  ;; 61
(assert-parse-error "conventional escape sequence" "\"\\>\"")  ;; 62
(assert-parse-error "conventional escape sequence" "\"\\?\"")  ;; 63
(assert-parse-error "conventional escape sequence" "\"\\@\"")  ;; 64
(assert-parse-error "conventional escape sequence" "\"\\A\"")  ;; 65
(assert-parse-error "conventional escape sequence" "\"\\B\"")  ;; 66
(assert-parse-error "conventional escape sequence" "\"\\C\"")  ;; 67
(assert-parse-error "conventional escape sequence" "\"\\D\"")  ;; 68
(assert-parse-error "conventional escape sequence" "\"\\E\"")  ;; 69
(assert-parse-error "conventional escape sequence" "\"\\F\"")  ;; 70
(assert-parse-error "conventional escape sequence" "\"\\G\"")  ;; 71
(assert-parse-error "conventional escape sequence" "\"\\H\"")  ;; 72
(assert-parse-error "conventional escape sequence" "\"\\I\"")  ;; 73
(assert-parse-error "conventional escape sequence" "\"\\J\"")  ;; 74
(assert-parse-error "conventional escape sequence" "\"\\K\"")  ;; 75
(assert-parse-error "conventional escape sequence" "\"\\L\"")  ;; 76
(assert-parse-error "conventional escape sequence" "\"\\M\"")  ;; 77
(assert-parse-error "conventional escape sequence" "\"\\N\"")  ;; 78
(assert-parse-error "conventional escape sequence" "\"\\O\"")  ;; 79
(assert-parse-error "conventional escape sequence" "\"\\P\"")  ;; 80
(assert-parse-error "conventional escape sequence" "\"\\Q\"")  ;; 81
(assert-parse-error "conventional escape sequence" "\"\\R\"")  ;; 82
(assert-parse-error "conventional escape sequence" "\"\\S\"")  ;; 83
(assert-parse-error "conventional escape sequence" "\"\\T\"")  ;; 84
(assert-parse-error "conventional escape sequence" "\"\\U\"")  ;; 85
(assert-parse-error "conventional escape sequence" "\"\\V\"")  ;; 86
(assert-parse-error "conventional escape sequence" "\"\\W\"")  ;; 87
(assert-parse-error "conventional escape sequence" "\"\\X\"")  ;; 88
(assert-parse-error "conventional escape sequence" "\"\\Y\"")  ;; 89
(assert-parse-error "conventional escape sequence" "\"\\Z\"")  ;; 90
(assert-parse-error "conventional escape sequence" "\"\\[\"")  ;; 91
;;                                                      "\\"   ;; 92
(assert-parse-error "conventional escape sequence" "\"\\]\"")  ;; 93
(assert-parse-error "conventional escape sequence" "\"\\^\"")  ;; 94
(assert-parse-error "conventional escape sequence" "\"\\_\"")  ;; 95
(assert-parse-error "conventional escape sequence" "\"\\`\"")  ;; 96
;;                                                      "\a"   ;; 97
;;                                                      "\b"   ;; 98
(assert-parse-error "conventional escape sequence" "\"\\c\"")  ;; 99
(assert-parse-error "conventional escape sequence" "\"\\d\"")  ;; 100
(assert-parse-error "conventional escape sequence" "\"\\e\"")  ;; 101
;;                                                      "\f"   ;; 102
(assert-parse-error "conventional escape sequence" "\"\\g\"")  ;; 103
(assert-parse-error "conventional escape sequence" "\"\\h\"")  ;; 104
(assert-parse-error "conventional escape sequence" "\"\\i\"")  ;; 105
(assert-parse-error "conventional escape sequence" "\"\\j\"")  ;; 106
(assert-parse-error "conventional escape sequence" "\"\\k\"")  ;; 107
(assert-parse-error "conventional escape sequence" "\"\\l\"")  ;; 108
(assert-parse-error "conventional escape sequence" "\"\\m\"")  ;; 109
;;                                                      "\n"   ;; 110
(assert-parse-error "conventional escape sequence" "\"\\o\"")  ;; 111
(assert-parse-error "conventional escape sequence" "\"\\p\"")  ;; 112
(assert-parse-error "conventional escape sequence" "\"\\q\"")  ;; 113
;;                                                      "\r"   ;; 114
(assert-parse-error "conventional escape sequence" "\"\\s\"")  ;; 115
;;                                                      "\t"   ;; 116
(assert-parse-error "conventional escape sequence" "\"\\u\"")  ;; 117
;;                                                      "\v"   ;; 118
(assert-parse-error "conventional escape sequence" "\"\\w\"")  ;; 119
(assert-parse-error "conventional escape sequence" "\"\\x\"")  ;; 120
(assert-parse-error "conventional escape sequence" "\"\\y\"")  ;; 121
(assert-parse-error "conventional escape sequence" "\"\\z\"")  ;; 122
(assert-parse-error "conventional escape sequence" "\"\\{\"")  ;; 123
;;                                                      "\|"   ;; 124
(assert-parse-error "conventional escape sequence" "\"\\}\"")  ;; 125
(assert-parse-error "conventional escape sequence" "\"\\~\"")  ;; 126

;; raw control chars
(tn "raw control char in string literal")
(assert-equal? (tn) (integer->string   0) " ")  ;; 0
(assert-equal? (tn) (integer->string   1) "")  ;; 1
(assert-equal? (tn) (integer->string   2) "")  ;; 2
(assert-equal? (tn) (integer->string   3) "")  ;; 3
(assert-equal? (tn) (integer->string   4) "")  ;; 4
(assert-equal? (tn) (integer->string   5) "")  ;; 5
(assert-equal? (tn) (integer->string   6) "")  ;; 6
(assert-equal? (tn) (integer->string   7) "")  ;; 7
(assert-equal? (tn) (integer->string   8) "")  ;; 8  ;; DON'T EDIT THIS LINE!
(assert-equal? (tn) (integer->string   9) "	")  ;; 9
(assert-equal? (tn) (integer->string  10) "
")  ;; 10 ;; DON'T EDIT THIS LINE!
(assert-equal? (tn) (integer->string  11) "")  ;; 11
(assert-equal? (tn) (integer->string  12) "")  ;; 12
(assert-equal? (tn) (integer->string  13) "
(assert-equal? (tn) (integer->string  14) "")  ;; 14
(assert-equal? (tn) (integer->string  15) "")  ;; 15
(assert-equal? (tn) (integer->string  16) "")  ;; 16
(assert-equal? (tn) (integer->string  17) "")  ;; 17
(assert-equal? (tn) (integer->string  18) "")  ;; 18
(assert-equal? (tn) (integer->string  19) "")  ;; 19
(assert-equal? (tn) (integer->string  20) "")  ;; 20
(assert-equal? (tn) (integer->string  21) "")  ;; 21
(assert-equal? (tn) (integer->string  22) "")  ;; 22
(assert-equal? (tn) (integer->string  23) "")  ;; 23
(assert-equal? (tn) (integer->string  24) "")  ;; 24
(assert-equal? (tn) (integer->string  25) "")  ;; 25 ;; DON'T EDIT THIS LINE!
(assert-equal? (tn) (integer->string  26) "")  ;; 26
(assert-equal? (tn) (integer->string  27) "")  ;; 27
(assert-equal? (tn) (integer->string  28) "")  ;; 28
(assert-equal? (tn) (integer->string  29) "")  ;; 29
(assert-equal? (tn) (integer->string  30) "")  ;; 30
(assert-equal? (tn) (integer->string  31) "")  ;; 31
(assert-equal? (tn) (integer->string 127) "")  ;; 127

;; escaped raw control chars
;;(assert-parse-error "escaped raw control char in string literal" "\"\\ \"")  ;; 0  ;; cannot read by string port
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 1
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 2
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 3
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 4
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 5
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 6
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 7
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 8  ;; DON'T EDIT THIS LINE!
(assert-parse-error "escaped raw control char in string literal" "\"\\	\"")  ;; 9
(assert-parse-error "escaped raw control char in string literal" "\"\\
\"")  ;; 10  ;; DON'T EDIT THIS LINE!
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 11
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 12
(assert-parse-error "escaped raw control char in string literal" "\"\\
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 14
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 15
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 16
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 17
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 18
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 19
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 20
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 21
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 22
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 23
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 24
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 25  ;; DON'T EDIT THIS LINE!
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 26
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 27
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 28
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 29
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 30
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 31
(assert-parse-error "escaped raw control char in string literal" "\"\\\"")  ;; 127

(total-report)