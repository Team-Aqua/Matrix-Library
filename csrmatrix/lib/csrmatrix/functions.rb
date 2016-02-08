module CsrMatrix
    module Functions
        include Contracts::Core
        include Contracts::Builtin

        def self.included(exceptions)
            exceptions.send :include, Exceptions
        end

        def determinant()
            # identifies the determinant of a matrix
            # pre   existing matrix
            # post  determinant of the matrix
            if !self.square?()
                raise Exceptions::MatrixDimException.new, "Matrix is not square."
                return false
            end
            m = Matrix.rows(self.decompose)
            return m.det()
        end # determinant

        def det()
            # alias for determinant
            # identifies the determinant of a matrix
            # pre   existing matrix
            # post  determinant of the matrix
            return self.determinant()
        end # det

        Contract Contracts::Send[:not_null?] => Contracts::Num
        def rank()
            # identifies the rank of a matrix
            # pre   existing matrix (matrix.not_null?)
            # post  rank of the matrix
            m = Matrix.rows(self.decompose)
            return m.rank()
        end # rank

        def round(ndig = 0)
            # identifies the round of a matrix (that is, each value rounded by a specific degree)
            # pre   integer of degree, existing matrix (matrix.not_null?)
            # post  rounded array
            for i in 0..self.val.count-1
                self.val[i] = self.val[i].round(ndig)
            end    
        end # round

        Contract Contracts::Send[:not_null?] => Contracts::Num
        def trace()
            # identifies the trace of the matrix
            # pre   existing matrix (matrix.not_null?)
            # post  trace
            m = Matrix.rows(self.decompose)
            return m.trace()
        end # trace

        Contract Contracts::Send[:not_null?] => Contracts::Num
        def tr()
            # alias for trace
            # identifies the trace of the matrix
            # pre   existing matrix (matrix.not_null?)
            # post  trace
            return self.trace()
        end # tr

    end # Functions
end # CsrMatrix
