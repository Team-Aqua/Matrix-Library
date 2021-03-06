require "minitest/autorun"
require "csrmatrix"

class PropertiesTest < Minitest::Test

  def setup
    @matrix = TwoDMatrix.new

    @matrixDense3x3 = TwoDMatrix.new
    @matrixDense3x3.build_from_array([[1, 2, 3], [1, 2, 3], [1, 2, 3]])

		@matrixNotSquare2x3 = TwoDMatrix.new
		@matrixNotSquare2x3.build_from_array([[1, 2], [1, 2], [1, 2]])

    @matrixSparse3x3 = TwoDMatrix.new
    @matrixSparse3x3.build_from_array([[0, 1, 0], [2, 0, 0], [0, 0, 3]])

    @matrixTrigonal3x3 = TwoDMatrix.new
    @matrixTrigonal3x3.build_from_array([[-1, 0, 0], [0, -1, 0], [0, 0, -1]])

		@matrixSymmetric3x3 = TwoDMatrix.new
    @matrixSymmetric3x3.build_from_array([[-1, 2, 5], [2, -1, 0], [5, 0, -1]])

		@matrixEmpty3x3 = TwoDMatrix.new
    @matrixEmpty3x3.build_from_array([[],[],[]])

		@matrixZero3x3 = TwoDMatrix.new
    @matrixZero3x3.build_from_array([[0, 0, 0], [0, 0, 0], [0, 0, 0]])

    @matrixnull = TwoDMatrix.new
		#@matrixHermitian3x3 = TwoDMatrix.new
		#@matrixHermitian3x3.build_from_array([[2, 2+i, 4], [2-i, 3, i], [4, -i, 1]])
  end

  def test_diagonal
    assert @matrixTrigonal3x3.diagonal?
  end

  def test_err_diagonal
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.diagonal?}    
  end

	def test_empty
    assert @matrixEmpty3x3.empty?
  end

  def test_err_empty
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.empty?}    
  end

	def test_lower_triangle
    assert @matrixTrigonal3x3.lower_triangular?
  end

  def test_err_lower_triangle
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.lower_triangular?}    
  end

	def test_normal
    assert @matrixTrigonal3x3.normal?
  end

  def test_err_normal
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.normal?}    
  end

	def test_invalid_normal
		assert_raises(CsrMatrix::Exceptions::MatrixDimException) { @matrixNotSquare2x3.normal? }
  end

	def test_orthogonal
    assert @matrixTrigonal3x3.orthogonal?
  end

  def test_err_orthogonal
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.orthogonal?}    
  end

	def test_invalid_orthogonal
		assert_raises(CsrMatrix::Exceptions::MatrixDimException) { @matrixNotSquare2x3.orthogonal? }
  end

	def test_permutation
    assert !@matrixSparse3x3.permutation?
  end

  def test_err_permutation
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.permutation?}    
  end

	def test_invalid_permutation
		assert_raises(CsrMatrix::Exceptions::MatrixDimException) { @matrixNotSquare2x3.permutation? }
  end

	def test_real
    assert @matrixSparse3x3.real?
  end

  def test_err_real
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.real?}    
  end

	def test_nonsingular
    assert @matrixTrigonal3x3.nonsingular?
  end

  def test_err_nonsingular
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.nonsingular?}    
  end

	def test_singular
    assert @matrixDense3x3.singular?
  end

  def test_err_singular
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.singular?}    
  end

	def test_square
    assert @matrixDense3x3.square?
  end

  def test_err_square
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.square?}    
  end

	def test_symmetric
    assert @matrixSymmetric3x3.symmetric?
  end

  def test_err_symmetric
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.symmetric?}    
  end

	def test_invalid_symmetric
		assert_raises(CsrMatrix::Exceptions::MatrixDimException) { @matrixNotSquare2x3.symmetric? }
  end

	def test_unitary
    assert @matrixTrigonal3x3.unitary?
  end

  def test_err_unitary
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.unitary?}    
  end

	def test_invalid_unitary
		assert_raises(CsrMatrix::Exceptions::MatrixDimException) { @matrixNotSquare2x3.unitary? }
  end

	def test_upper_triangular
    assert @matrixTrigonal3x3.upper_triangular?
  end

  def test_err_upper_triangular
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.upper_triangular?}    
  end

	def test_zero
    assert @matrixZero3x3.zero?
  end

  def test_err_zero
    assert_raises(CsrMatrix::Exceptions::InvariantError) { @matrixnull.zero?}    
  end

end 
