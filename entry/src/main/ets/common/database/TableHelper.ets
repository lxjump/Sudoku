/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ColumnInfo from '../../viewmodel/ColumnInfo';
import {LogUtil} from '../../utils/LogUtil';

class TableHelper {
  createTableSql(tableName: string, columns: Array<ColumnInfo>): string {
    let sql = `create table if not exists ${tableName}(`;
    for (let column of columns) {
      //Logger.info(`我来看看column是什么 : ${JSON.stringify(columns)},kkkkkkk${JSON.stringify(tableName)}`);
      sql = sql.concat(`${column.name} ${column.type}`);
      sql = sql.concat(`${column.length && column.length > 0 ? `(${column.length})` : ''}`);
      sql = sql.concat(`${column.primary ? ' primary key' : ''}`);
      sql = sql.concat(`${column.autoincrement ? ' autoincrement' : ''}`);
      sql = sql.concat(`${column.nullable ? '' : ' not null'}`);
      sql = sql.concat(', ');
      LogUtil.info('sql是啥啊',sql)
    }
    sql = `${sql.substring(0, sql.length - 2)})`;
    return sql;
  }

  addTableColumnSql(tableName: string, column: ColumnInfo): string {
    LogUtil.info(`TableHelper updateTableSql : ${JSON.stringify(column)}`);
    let sql = `alter table ${tableName} add `;
    sql = sql.concat(`${column.name} ${column.type}`);
    sql = sql.concat(`${column.length && column.length > 0 ? `(${column.length})` : ''}`);
    LogUtil.info(`TableHelper updateTableSql : ` + sql);
    return sql;
  }

  deleteTableSql(tableName: string): string {
    LogUtil.info(`TableHelper deleteTableSql : ${JSON.stringify(tableName)}`);
    return `drop table if exists ${tableName}`;
  }
}

const tableHelper = new TableHelper();

export default tableHelper;