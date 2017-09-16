/**
 * Copyright 2017 University of Victoria
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
package com.rigiresearch.examgen.templates

import com.rigiresearch.examgen.model.CompoundText
import com.rigiresearch.examgen.model.Examination
import com.rigiresearch.examgen.model.Question
import com.rigiresearch.examgen.model.TextSegment

import static com.rigiresearch.examgen.model.Examination.Parameter.COURSE
import static com.rigiresearch.examgen.model.Examination.Parameter.COURSE_REFERENCE_NUMBER
import static com.rigiresearch.examgen.model.Examination.Parameter.TERM
import static com.rigiresearch.examgen.model.Examination.Parameter.TIME_LIMIT
import static com.rigiresearch.examgen.model.Examination.Parameter.TITLE
import com.rigiresearch.examgen.model.OpenEnded
import com.rigiresearch.examgen.model.ClosedEnded
import com.rigiresearch.examgen.model.CompoundQuestion
import static com.rigiresearch.examgen.model.Examination.Parameter.SECTIONS

/**
 * A Latex template implementation.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2017-09-14
 * @version $Id$
 * @since 0.0.1
 */
class LatexQuiz implements Template {

    override render(Examination e, boolean printSolutions) '''
        \documentclass[10pt,addpoints«IF printSolutions»,answers«ENDIF»]{exam}
        
        % packages configuration
        «packages»
        
        % listings configuration
        «listings»
        
        % parameters
        \newcommand{\institution}{University of Victoria}
        \newcommand{\course}{«e.parameters.get(COURSE)»}
        \newcommand{\coursenumber}{«e.parameters.get(COURSE_REFERENCE_NUMBER)»}
        \newcommand{\sections}{«e.parameters.get(SECTIONS)»}
        \newcommand{\term}{«e.parameters.get(TERM)»}
        \newcommand{\timelimit}{«e.parameters.get(TIME_LIMIT)»}
        \newcommand{\examtitle}{«e.parameters.get(TITLE)»}
        
        % page configuration
        \pagestyle{head}
        \firstpageheader{}{}{}
        \runningheader{\footnotesize \coursenumber}{\footnotesize \examtitle\ - Page \thepage\ of \numpages}{\footnotesize \term}
        \runningheadrule
        
        \begin{document}
        % header
        \noindent
        \section*{\examtitle}
        \textbf{\course{}  -- \term{}} \\
        {\footnotesize \coursenumber{} Section \sections. Time limit: \timelimit{}. Circle the appropriate letter in multiple choice questions.} \\
        
        % student information
        \noindent
        \begin{tabularx}{\textwidth}{|X|X|X|X|X|X|}
            \hline
            \small{Student name} & \small{} & \small{Student ID} & \small\bfseries{V00} & \small{Grade} & \small{} \\
            \hline
        \end{tabularx}
        
        \noindent \\
        \rule[2ex]{\textwidth}{2pt}
        
        \centering
        {\footnotesize This exam is worth a total of \numpoints{} marks and contains \numquestions{} questions on \numpages{} pages.}
        
        \begin{questions}
        \bracketedpoints
        \marksnotpoints
        «FOR q : e.questions SEPARATOR "\n"»
        «q.render(printSolutions)»
        «ENDFOR»
        \end{questions}
        \end{document}
    '''

    override render(Question question, boolean printSolutions) {
        switch (question) {
            OpenEnded: question.render(false, printSolutions)
            ClosedEnded: question.render(false, printSolutions)
            CompoundQuestion: question.render(printSolutions)
        }
    }

    override render(TextSegment segment) {
        switch (segment) {
            TextSegment.Simple: segment.styled
            CompoundText: segment.segments.map[it.styled].join(" ")
        }
    }

    /**
     * Applies styles to a rendered text segment.
     */
    def styled(TextSegment segment) {
        var CharSequence result = segment.text
        for (style : segment.styles) {
            result = result.styled(style)
        }
        return if (segment.styles.contains(TextSegment.Style.NEW_LINE))
            "\n" + result
        else
            result
    }

    /**
     * Applies the given style to a rendered text.
     */
    def styled(CharSequence text, TextSegment.Style style) {
        switch (style) {
            case BOLD: '''\textbf{«text.escaped»}'''
            case CODE: '''
            \vspace{0.3cm}
            \begin{lstlisting}
            «text»
            \end{lstlisting}
            '''
            case INLINE_CODE: '''\lstinline|«text»|'''
            case ITALIC: '''\textit{«text.escaped»}'''
            case CUSTOM: text
            case INHERIT: text.escaped
            case NEW_LINE: '''\n«text.escaped»'''
        }
    }

    /**
     * Escapes special Latex characters
     */
    def escaped(CharSequence text) {
        text.toString
            .replace("\\", "\\textbackslash")
            .replace("~", "\\textasciitilde")
            .replace("^", "\\textasciicircum")
            .replace("#", "\\#")
            .replace("&", "\\&")
            .replace("%", "\\%")
            .replace("{", "\\{")
            .replace("}", "\\}")
            .replace("$", "\\$")
            .replace("_", "\\_")
    }

    /**
     * Renders an open-ended question.
     */
    def render(OpenEnded question, boolean child, boolean printSolutions) '''
        «IF !child»\question[«question.points»]«ENDIF»
        «question.statement.render»
        «IF printSolutions»
            \begin{solution}
                «question.answer.render»
            \end{solution}
        «ELSE»
            \makeemptybox{«question.expectedLength»}
        «ENDIF»
    '''

    /**
     * Renders a closed-ended question.
     */
    def render(ClosedEnded question, boolean child, boolean printSolutions) '''
        «IF !child»\question[«question.points»]«ENDIF»
        «question.statement.render»
        \begin{choices}
            «FOR option : question.options»
                «IF option.answer»\CorrectChoice«ELSE»\choice«ENDIF» «option.statement.render»
            «ENDFOR»
        \end{choices}
    '''

    /**
     * Renders a compound question.
     */
    def render(CompoundQuestion question, boolean printSolutions) '''
        \question[«question.points»]
        «question.statement.render»
        \noaddpoints % to omit double points count
        \begin{parts}
            «FOR child : question.children SEPARATOR "\n"»
                \part[«child.points»]{}
                «
                    switch (child) {
                        OpenEnded: child.render(true, printSolutions)
                        ClosedEnded: child.render(true, printSolutions)
                    }
                »
            «ENDFOR»
        \end{parts}
        \addpoints
    '''

    /**
     * Renders the packages to configure the Latex document.
     */
    def packages() '''
    % general
    \usepackage[utf8]{inputenc}
    \usepackage[margin=1in]{geometry}
    % math
    \usepackage{amsmath, amssymb}
    % tables
    \usepackage{tabularx}
    \usepackage{multicol}
    % listings
    \usepackage{color}
    \usepackage[scaled=0.85]{sourcecodepro}
    \usepackage{listings}
    '''

    /**
     * Configures the Latex listings.
     */
    def listings() '''
    \definecolor{keywords}{RGB}{127,0,85}
    \definecolor{comments}{RGB}{63,127,95}
    \definecolor{strings}{RGB}{42,0,255}
    \definecolor{frame}{RGB}{150,150,150}
    \definecolor{numbers}{RGB}{100,100,100}
    \lstdefinestyle{code}{
        language=C,
        tabsize=4,
        captionpos=b,
        showspaces=false,
        showtabs=false,
        breaklines=true,
        showstringspaces=false,
        breakatwhitespace=true,
        escapeinside={(*@}{@*)},
        commentstyle=\color{comments},
        keywordstyle=\bfseries\color{keywords},
        stringstyle=\color{strings},
        basicstyle=\small\ttfamily,
        frame=lines,
        rulecolor=\color{frame},
        xleftmargin=2em,
        framexleftmargin=1.5em,
        numbers=left,
        numbersep=10pt,
        numberstyle=\scriptsize\ttfamily\color{numbers}
    }
    \lstset{style=code}
    '''

}