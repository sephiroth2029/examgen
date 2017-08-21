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
package com.rigiresearch.examgen.model;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.experimental.Accessors;

/**
 * A written examination.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2017-08-20
 * @version $Id$
 * @since 0.0.1
 */
@Accessors(fluent = true)
@AllArgsConstructor
@Getter
public final class Examination {

    /**
     * Parameters regarding this exam.
     * @author Miguel Jimenez (miguel@uvic.ca)
     * @date 2017-08-21
     * @version $Id$
     * @since 0.0.1
     */
    public enum Parameter {
        /**
         * The class to which this exam belongs.
         */
        CLASS,

        /**
         * The expected date in which this exam takes place.
         */
        DATE,

        /**
         * The specific class section, if any.
         */
        SECTION,

        /**
         * The corresponding term.
         */
        TERM,

        /**
         * The time allocated to this exam.
         */
        TIME_LIMIT,

        /**
         * This exam's title.
         */
        TITLE,
    }

    /**
     * Optional fields regarding the student's information.
     * @author Miguel Jimenez (miguel@uvic.ca)
     * @date 2017-08-21
     * @version $Id$
     * @since 0.0.1
     */
    public enum Field {
        /**
         * The assigned grade.
         */
        GRADE,

        /**
         * The student identification number.
         */
        STUDENT_ID,

        /**
         * The student name.
         */
        STUDENT_NAME,
    }

    /**
     * Parameters composing the document header. Values are expected.
     */
    private final Map<Parameter, String> parameters;

    /**
     * Fields printed below the document header. Values are optional.
     */
    private final Map<Field, String> fields;

    /**
     * This examination's set of questions.
     */
    private final List<Question> questions;

    /**
     * Scramble this exam.
     * @param seed the seed for the random number generator
     * @return a scrambled version of this exam
     */
    public Examination scrambled(final long seed) {
        final List<Question> scrambledQuestions = this.questions.stream()
            .map(question -> question.scrambled(seed))
            .collect(Collectors.toList());
        Collections.shuffle(
            scrambledQuestions,
            new Random(seed)
        );
        return new Examination(
            this.parameters,
            this.fields,
            scrambledQuestions
        );
    }

}
