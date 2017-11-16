# frozen_string_literal: true

require 'spec_helper'

require 'tempfile'
require 'chproxy/executor'

RSpec.describe Chproxy::Executor do
  let(:cli) { FakeCli.new }
  let(:tempfile) { Tempfile.new(%w[gradle .properties]) }
  let(:dest) do
    tempfile.write('proxy=cache:3128')
    tempfile.close
    tempfile.path
  end

  context 'rewriter' do
    subject { described_class.rewriter(cli, dest, label: 'gradle properties') }

    context '#update' do
      it 'rewrites the file if the content differs' do
        expect(subject.update('proxy=proxy:3128')).to be_truthy
        expect(cli.messages.first).to match(/\*yellow\* \[UPDATE\]: chproxy: gradle.*update/)
        expect(File.read(dest)).to eq 'proxy=proxy:3128'
      end

      it 'skips the update when there are no changes' do
        expect(subject.update('proxy=cache:3128')).to be_falsey
        expect(cli.messages.first).to match(/\*green\* \[SKIP\]: chproxy: gradle.*no change/)
      end

      context 'with dry_run: true' do
        subject { described_class.rewriter(cli, dest, label: 'gradle properties', dry_run: true) }

        it 'pretends to rewrite the file if the content differs' do
          expect(subject.update('proxy=proxy:3128')).to be_truthy
          expect(cli.messages.first).to match(/\*yellow\* \[UPDATE\]: chproxy: gradle.*update/)
          expect(File.read(dest)).to eq 'proxy=cache:3128'
        end
      end
    end
  end

  context 'deleter' do
    subject { described_class.deleter(cli, dest, label: 'gradle properties') }
    after { File.unlink(subject.dest) rescue nil }

    context '#update' do
      it 'creates the dest if there is content' do
        expect(subject.update('proxy=proxy:3128')).to be_truthy
        expect(cli.messages.first).to match(/\*yellow\* \[UPDATE\]: chproxy: gradle.*update/)
        expect(File.read(subject.dest)).to eq 'proxy=proxy:3128'
      end

      it 'rewrites existing content' do
        expect(subject.update('proxy=proxy:3128')).to be_truthy
        expect(cli.messages.first).to match(/\*yellow\* \[UPDATE\]: chproxy: gradle.*update/)
        expect(File.read(dest)).to eq 'proxy=proxy:3128'
      end

      it 'skips the update when there are no changes' do
        expect(subject.update('proxy=cache:3128')).to be_falsey
        expect(cli.messages.first).to match(/\*green\* \[SKIP\]: chproxy: gradle.*no change/)
      end

      it 'deletes the file if there is no content' do
        expect(subject.update(nil)).to be_truthy
        expect(cli.messages.first).to match(/\*red\* \[REMOVE\]: chproxy: gradle.*no proxy/)
        expect(File.file?(dest)).to be_falsey
      end

      context 'with dry_run: true' do
        subject { described_class.deleter(cli, dest, label: 'gradle properties', dry_run: true) }

        it 'pretends to rewrite the existing content' do
          expect(subject.update('proxy=proxy:3128')).to be_truthy
          expect(cli.messages.first).to match(/\*yellow\* \[UPDATE\]: chproxy: gradle.*update/)
          expect(File.read(dest)).to eq 'proxy=cache:3128'
        end

        it 'pretends to delete the file if there is no content' do
          expect(subject.update(nil)).to be_truthy
          expect(cli.messages.first).to match(/\*red\* \[REMOVE\]: chproxy: gradle.*no proxy/)
          expect(File.file?(dest)).to be_truthy
        end
      end
    end
  end
end
