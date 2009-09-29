require 'minitest/autorun'
require 'psych'

module Psych
  module Visitors
    class TestEmitter < MiniTest::Unit::TestCase
      def setup
        @io = StringIO.new
        @visitor = Visitors::Emitter.new @io
      end

      def test_stream
        s = Nodes::Stream.new
        @visitor.accept s
        assert_equal '', @io.string
      end

      def test_document
        s       = Nodes::Stream.new
        doc     = Nodes::Document.new [1,1]
        scalar  = Nodes::Scalar.new 'hello world'

        doc.children << scalar
        s.children << doc

        @visitor.accept s

        assert_match(/1.1/, @io.string)
        assert_equal @io.string, s.to_yaml
      end

      def test_document_implicit_end
        s       = Nodes::Stream.new
        doc     = Nodes::Document.new
        mapping = Nodes::Mapping.new
        mapping.children << Nodes::Scalar.new('key')
        mapping.children << Nodes::Scalar.new('value')
        doc.children << mapping
        s.children << doc

        @visitor.accept s

        assert_match(/key: value/, @io.string)
        assert_equal @io.string, s.to_yaml
        assert(/\.\.\./ !~ s.to_yaml)
      end

      def test_scalar
        s       = Nodes::Stream.new
        doc     = Nodes::Document.new
        scalar  = Nodes::Scalar.new 'hello world'

        doc.children << scalar
        s.children << doc

        @visitor.accept s

        assert_match(/hello/, @io.string)
        assert_equal @io.string, s.to_yaml
      end

      def test_sequence
        s       = Nodes::Stream.new
        doc     = Nodes::Document.new
        scalar  = Nodes::Scalar.new 'hello world'
        seq     = Nodes::Sequence.new

        seq.children << scalar
        doc.children << seq
        s.children << doc

        @visitor.accept s

        assert_match(/- hello/, @io.string)
        assert_equal @io.string, s.to_yaml
      end

      def test_mapping
        s       = Nodes::Stream.new
        doc     = Nodes::Document.new
        mapping = Nodes::Mapping.new
        mapping.children << Nodes::Scalar.new('key')
        mapping.children << Nodes::Scalar.new('value')
        doc.children << mapping
        s.children << doc

        @visitor.accept s

        assert_match(/key: value/, @io.string)
        assert_equal @io.string, s.to_yaml
      end
    end
  end
end
