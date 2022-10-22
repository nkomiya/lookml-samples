LookML のサンプルコード集
#########################

ブランチごとにサンプルを格納する。

サンプル一覧
============

+-------------------------------------------+------------------------------+
| ブランチ名                                | 概要                         |
+-------------------------------------------+------------------------------+
| `pop-patterns <../../tree/pop-patterns>`_ | 期間比較分析のサンプル集     |
+-------------------------------------------+------------------------------+


使い方
======

この LookML プロジェクトを読み込んで使ってください。

リポジトリの参照設定
--------------------

まず、このリポジトリのファイルを、LookML プロジェクトで参照するための設定を行います。

(1) 未作成の場合は空の manifest ファイルを作成。
(2) manifest ファイルにリポジトリの参照設定を追記。

    下記記載で、LookML プロジェクトでこのリポジトリのファイルを include できるようになります。

    .. code-block:: lookml

        remote_dependency: REMOTE_DEPENDENCY_NAME {
            url: "https://github.com/nkomiya/lookml-samples.git"
            ref: "BRANCH_NAME"
        }

    BRANCH_NAME には取り込みたいブランチの名称を指定してください。

    | REMOTE_DEPENDENCY_NAME は任意の名称で問題ないですが、分かりやすい名称が良いと思います。
    | (後のステップで、ファイルを include する際に使います)


explore の読み込み
------------------

| model ファイルに下記コードを追加すると、取り込むブランチの /explores 配下で定義された explore が、
| model に読み込まれます (Explore で使えるようになります)。

.. code-block:: lookml

    include: "//REMOTE_DEPENDENCY_NAME/explores/*.explore"

REMOTE_DEPENDENCY_NAME は先の手順で指定した remote_dependency の名称です。

定義の拡張
----------

取り込んだ view 等で定義の変更を行いたい場合は refinement を使ってください。

以下、非表示の dimension を表示させるサンプルコードです。

.. code-block:: lookml

    include: "//REMOTE_DEPENDENCY_NAME/views/some_view.view"

    view: +some_view {
        dimension: some_hidden_dimension {
          hidden: no
        }
    }

同じく、REMOTE_DEPENDENCY_NAME は先の手順で指定した remote_dependency の名称です。
