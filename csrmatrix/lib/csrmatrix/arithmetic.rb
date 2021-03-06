require "matrix"
require "csrmatrix/exceptions"
require "contracts"
require "csrmatrix/mcontracts"

module CsrMatrix    
  module Arithmetic
    include Contracts::Core
    C = Contracts

    # Brings in exception module for exception testing
    def self.included(exceptions)
      exceptions.send :include, Exceptions
    end

    Contract MContracts::ValidInputNum => C::ArrayOf[MContracts::ValidMatrixNum]
    def scalar_multiply(value)
      # multiply the matrix by a scalar value
      is_invariant?

      @val.each_index do |i|
        @val[i] = @val[i] * value
      end
      @val
    end # scalar_multiply
    
    Contract MContracts::ValidInputNum => C::ArrayOf[MContracts::ValidMatrixNum]
    def scalar_add(value)
      # manipulate the matrix by adding a value at each index
      is_invariant?

      @val.each_index do |i|
        @val[i] = @val[i] + value
      end
      @val
    end # scalar_add

    Contract MContracts::ValidInputNum => C::ArrayOf[MContracts::ValidMatrixNum]
    def scalar_subtract(value)
      is_invariant? 

      # manipulate the matrix by subtracting the value at each index
      @val.each_index do |i|
        @val[i] = @val[i] - value
      end
      @val
    end # scalar_subtract

    Contract MContracts::ValidInputNum => C::ArrayOf[MContracts::ValidMatrixNum]
    def scalar_division(value)
      is_invariant?

      # manipulate the matrix by dividing the value at each index
      @val.each_index do |i|
        @val[i] = @val[i] / value.to_f
      end
      @val
    end # scalar_division

    Contract MContracts::ValidInputNum => C::ArrayOf[MContracts::ValidMatrixNum]
    def scalar_exp(value)
      is_invariant?

      # manipulate the matrix by finding the exponential at each index
      @val.each_index do |i|
        @val[i] = @val[i] ** value
      end
      @val
    end # scalar_exp

    Contract C::None => C::ArrayOf[MContracts::ValidMatrixNum]
    def inverse()
      is_invariant?
      # sets the inverse of this matrix
      m = Matrix.rows(self.decompose)
      self.build_from_array(m.inv().to_a())
      @val
    end # inverse

    Contract C::None => C::ArrayOf[MContracts::ValidMatrixNum]
    def transpose()
      is_invariant?
      # transpose the matrix 

			new_row_ptr = Array.new(self.columns+1, 0)
			new_col_ind = Array.new(self.col_ind.count(), 0)
			new_val = Array.new(self.val.count(), 0)
			current_row = 0
			current_column = 0
	
			for i in 0..self.columns-1
				for j in 0..self.col_ind.count(i)-1
					# get the row
					index = self.col_ind.find_index(i)
					self.col_ind[index] = -1
					for k in 1..self.row_ptr.count()-1
						if self.row_ptr[k-1] <= index && index < self.row_ptr[k]
							current_row = k
							break
						end
					end

					# update values
					new_row_ptr[i+1] += 1
					new_val[current_column] = val[index]
					new_col_ind[current_column] = current_row-1
					current_column += 1
				end
			end

			# fill in row_ptr
			for i in 1..self.rows-1
				self.row_ptr[i] = new_row_ptr[i] + new_row_ptr[i-1]
			end	

			@col_ind = new_col_ind
			@val = new_val
    end # transpose

    Contract C::None => C::ArrayOf[MContracts::ValidMatrixNum]
    def t()
      is_invariant?
      # transpose the matrix 
			self.transpose()
      @val
    end # t

    Contract Array => C::ArrayOf[MContracts::ValidMatrixNum]
    def matrix_vector(vector) 
      # dev based on http://www.mathcs.emory.edu/~cheung/Courses/561/Syllabus/3-C/sparse.html
      # multiplies the matrix by a vector value (in array form)
      is_invariant?
      result = Array.new(vector.length, 0)
      i = 0
      while i < vector.length do
        k = @row_ptr[i]
        while k < @row_ptr[i+1] do
          result[i] = result[i] + @val[k] * vector[@col_ind[k]]
          k += 1
        end
        i += 1
      end   
      return result
    end # matrix_vector

    # dev based on http://stackoverflow.com/questions/29598299/csr-matrix-matrix-multiplication
    Contract C::ArrayOf[C::ArrayOf[MContracts::ValidInputNum]] => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def matrix_multiply(matrix)
      # multiply dense (non-dense) matrix to csr matrix [eg. [1, 2]] x 2d array
      is_invariant?
      res = Array.new(max_row(matrix)) { Array.new(@columns, 0) } # first denotes row, second denotes columns
      n = matrix.length
      i = 0
      # res = dense X csr
      csr_row = 0 # Current row in CSR matrix
      while i < n do
        startv = @row_ptr[i] 
        endv = @row_ptr[i + 1]
        j = startv
        while j < endv do
          col = @col_ind[j]
          csr_value = @val[j]
          k = 0
          while k < n do
            dense_value = matrix[k][csr_row]
            res[k][col] += csr_value * dense_value
            k += 1
          end
          j += 1
        end
        csr_row += 1
        i += 1
      end
      return res
    end # matrix_multiply

    Contract MContracts::TwoDMatrixType => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def multiply_csr(matrix)
      # multiply two csr together - ref: http://www.mcs.anl.gov/papers/P5007-0813_1.pdf
      is_invariant?
      return matrix.matrix_multiply(self.decompose())
    end # multiply_csr

    Contract MContracts::TwoDMatrixType => C::Bool
    def is_same_dim(matrix)
      # helper function to determine dim count is equal
      is_invariant?
      return self.dimensions() == matrix.dimensions()
    end # is_same_dim

    Contract MContracts::TwoDMatrixType => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def matrix_add(matrix)
      # adds a matrix to existing matrix
      is_invariant?
      if !self.is_same_dim(matrix)
        raise Exceptions::MatrixDimException.new, "Matrix does not have same dimensions; cannot add."
        return false
      end

      res = Array.new(@rows) { Array.new(@columns, 0) }
      row_idx = 0
      cnta = 0 # total logged entries for matrix a 
      cntb = 0
      while row_idx < @rows # eg. 0 1 2
        rowa = @row_ptr[row_idx + 1] # eg. 0 2 4 7
        rowb = matrix.row_ptr[row_idx + 1]
        while cnta < rowa
          # keep adding values to res until they're equal
          res[row_idx][@col_ind[cnta]] += @val[cnta]
          cnta += 1;
        end
        while cntb < rowb
          res[row_idx][@col_ind[cntb]] += matrix.val[cntb]
          cntb += 1;
        end  
        row_idx += 1;
      end
      return res
    end # matrix_add

    Contract MContracts::TwoDMatrixType => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def matrix_subtract(matrix)
      # subtracts a matrix to existing matrix
      is_invariant?
      if !self.is_same_dim(matrix)
        raise Exceptions::MatrixDimException.new, "Matrix does not have same dimensions; cannot subtract."
        return false
      end

      res = Array.new(@rows) { Array.new(@columns, 0) }
      row_idx = 0
      cnta = 0 # total logged entries for matrix a 
      cntb = 0
      while row_idx < @rows # eg. 0 1 2
        rowa = @row_ptr[row_idx + 1] # eg. 0 2 4 7
        rowb = matrix.row_ptr[row_idx + 1]
        while cnta < rowa
          # keep adding values to res until they're equal
          res[row_idx][@col_ind[cnta]] += @val[cnta]
          cnta += 1;
        end
        while cntb < rowb
          res[row_idx][@col_ind[cntb]] -= matrix.val[cntb]
          cntb += 1;
        end  
        row_idx += 1;
      end
      return res
    end # matrix_subtract

    Contract MContracts::TwoDMatrixType => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def multiply_inverse(matrix)
      # divides (multiply by the inverse of ) a matrix to existing matrix
      # sets y * x^-1, where x is your matrix and y is the accepted matrix
      is_invariant?
      if !matrix.square? || !self.square?
        raise Exceptions::MatrixDimException.new, "Matrices does not have usable dimensions; cannot divide."
        return false
      end

      tmpmatrix = TwoDMatrix.new
      tmpmatrix = matrix
      tmpmatrix.inverse()
      return self.multiply_csr(tmpmatrix)
    end # matrix_inverse

    # multiply x by y^-1; x * y^-1 
    Contract MContracts::TwoDMatrixType => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def inverse_multiply(matrix)
      # divides (multiply by the inverse of ) a matrix to existing matrix
      # sets x * y^-1, where x is your matrix and y is the accepted matrix
      is_invariant?
      if !matrix.square? || !self.square?
        raise Exceptions::MatrixDimException.new, "Matrices does not have usable dimensions; cannot divide."
        return false
      end

      tmpmatrix = TwoDMatrix.new
      tmpmatrix = self
      tmpmatrix.inverse()
      return matrix.multiply_csr(tmpmatrix)
    end # inverse_multiply

    Contract C::None => C::Num
    def count_in_dim()
      is_invariant?
      # helper function, identifies the number of expected values in matrix
      # eg. 2x2 matrix returns 4 values
      return self.rows * self.columns
    end

    Contract MContracts::TwoDMatrixType => C::ArrayOf[C::ArrayOf[MContracts::ValidMatrixNum]]
    def matrix_division(matrix)
      # linear division of one matrix to the next
      is_invariant?
      if matrix.val.count() != matrix.count_in_dim()
        raise Exceptions::DivideByZeroException.new, "Calculations return divide by zero error."
        return false
      end 
      if !self.is_same_dim(matrix)
        raise Exceptions::MatrixDimException.new, "Matrix does not have same dimensions; cannot add."
        return false
      end

      res = Array.new(@rows) { Array.new(@columns, 0) }
      row_idx = 0
      cnta = 0 # total logged entries for matrix a 
      cntb = 0
      while row_idx < @rows # eg. 0 1 2
        rowa = @row_ptr[row_idx + 1] # eg. 0 2 4 7
        rowb = matrix.row_ptr[row_idx + 1]
        while cnta < rowa
          # keep adding values to res until they're equal
          res[row_idx][@col_ind[cnta]] += @val[cnta]
          cnta += 1;
        end
        while cntb < rowb
          res[row_idx][@col_ind[cntb]] = res[row_idx][@col_ind[cntb]].to_f / matrix.val[cntb]
          cntb += 1;
        end  
        row_idx += 1;
      end
      return res
    end # matrix_division

    Contract C::ArrayOf[MContracts::ValidInputNum] => C::Nat
    def max_row(array)
      # Identifies the 'row' value of an array (eg. the number of entries in a row)
      is_invariant?
      
      values = array
      max_count = 0
      values.each_index do |i|
        max_count += 1
      end
      return max_count
    end # max_row

  end # Arithmetic
end # CsrMatrix
