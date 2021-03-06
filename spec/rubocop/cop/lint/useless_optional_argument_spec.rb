# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UselessOptionalArgument do
  subject(:cop) { described_class.new }

  it 'registers an offense when an optional argument is followed by a ' \
     'required argument' do
    inspect_source(cop, ['def foo(a = 1, b)',
                         'end'])

    expect(cop.messages).to eq(['Useless optional argument for variable `a`.'])
    expect(cop.highlights).to eq(['a = 1'])
  end

  it 'registers an offense for each optional argument when multiple ' \
     'optional arguments are followed by a required argument' do
    inspect_source(cop, ['def foo(a = 1, b = 2, c)',
                         'end'])

    expect(cop.messages).to eq(['Useless optional argument for variable `a`.',
                                'Useless optional argument for variable `b`.'])
    expect(cop.highlights).to eq(['a = 1', 'b = 2'])
  end

  it 'allows methods without arguments' do
    inspect_source(cop, ['def foo',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only one required argument' do
    inspect_source(cop, ['def foo(a)',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only required arguments' do
    inspect_source(cop, ['def foo(a, b, c)',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only one optional argument' do
    inspect_source(cop, ['def foo(a = 1)',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows methods with only optional arguments' do
    inspect_source(cop, ['def foo(a = 1, b = 2, c = 3)',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows methods with multiple optional arguments at the end' do
    inspect_source(cop, ['def foo(a, b = 2, c = 3)',
                         'end'])

    expect(cop.messages).to be_empty
  end

  describe 'autocorrect' do
    it 'corrects a single useless optional arguments' do
      new_source = autocorrect_source(cop, ['def foo(a = 1, b)',
                                            'end'])

      expect(new_source).to eq(['def foo(a, b)',
                                'end'].join("\n"))
    end

    it 'corrects multiple useless optional arguments' do
      new_source = autocorrect_source(cop, ['def foo(a = 1, b = 2, c)',
                                            'end'])

      expect(new_source).to eq(['def foo(a, b, c)',
                                'end'].join("\n"))
    end
  end

  context 'named params' do
    context 'with default values', ruby_greater_than_or_equal: 2.0 do
      it 'allows optional arguments before an optional named argument' do
        inspect_source(cop, ['def foo(a = 1, b: 2)',
                             'end'])

        expect(cop.messages).to be_empty
      end
    end

    context 'required params', ruby_greater_than_or_equal: 2.1 do
      it 'registers an offense for optional arguments that come before ' \
         'required arguments where there are name arguments' do
        inspect_source(cop, ['def foo(a = 1, b, c:, d: 4)',
                             'end'])

        expect(cop.messages)
          .to eq(['Useless optional argument for variable `a`.'])
        expect(cop.highlights).to eq(['a = 1'])
      end

      it 'allows optional arguments before required named arguments' do
        inspect_source(cop, ['def foo(a = 1, b:)',
                             'end'])

        expect(cop.messages).to be_empty
      end

      it 'allows optional arguments to come before a mix of required and ' \
         'optional named argument' do
        inspect_source(cop, ['def foo(a = 1, b:, c: 3)',
                             'end'])

        expect(cop.messages).to be_empty
      end

      context 'autocorrect' do
        it 'removes the default values of optional arguments when they ' \
           'appear before required arguments and named arguments' do
          new_source = autocorrect_source(cop, ['def foo(a = 1, b, c:, d: 4)',
                                                'end'])

          expect(new_source).to eq(['def foo(a, b, c:, d: 4)',
                                    'end'].join("\n"))
        end
      end
    end
  end
end
