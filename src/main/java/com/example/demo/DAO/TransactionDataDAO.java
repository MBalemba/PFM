package com.example.demo.DAO;

import com.example.demo.Entity.TempEntity.GroupCodesOfClient;
import com.example.demo.ResponsesForWidgets.expensesByDay.Amount;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.sql.*;
import java.util.LinkedList;
import java.util.List;

@Component
public class TransactionDataDAO {

    @Value("${spring.datasource.url}")
    String url;
    @Value("${spring.datasource.username}")
    String name;
    @Value("${spring.datasource.password}")
    String pass;


    public double monthlyExpenses(Long id){
        String sql = "select \n" +
                "\tclient_id, \n" +
                "\tSUM(CAST(replace(sum, ',','.') as float8))*(-1) summary\n" +
                "from pfm_transaction_data \n" +
                "where CAST(replace(sum, ',','.') as float8) < 0 \n" +
                "and client_id = ? \n" +
                "GROUP BY client_id";
        double monthlyExpenses = 0;
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DriverManager.getConnection(url, name, pass);
            ps = con.prepareStatement(sql);
            ps.setLong(1, id);
            ResultSet r = ps.executeQuery();
            if(r.next()){
                monthlyExpenses = r.getDouble("summary");
            }
        } catch (SQLException throwable) {
            throwable.printStackTrace();
        }finally {
            try {
                if(con != null)
                    con.close();
                if(ps != null)
                    ps.close();
            } catch (SQLException throwables) {
                throwables.printStackTrace();
            }
        }
        return monthlyExpenses;
    }


    public List<GroupCodesOfClient> findGroupsCodeOfClient(Long id){

        String sql = "select \n" +
                "\tptd.client_id client_id, \n" +
                "\tCOUNT(ptd.mcc_code) \"count\",\n" +
                "\tSUM(CAST(replace(sum, ',','.') as float8) ) *(-1) summary, \n" +
                "\tpm.group_code group_code\n" +
                "from pfm_transaction_data ptd\n" +
                "join pfm_mcc pm ON pm.code = ptd.mcc_code\n" +
                "where CAST(replace(sum, ',','.') as float8) < 0 \n" +
                "and ptd.client_id = ?\n" +
                "group by pm.group_code, ptd.client_id\n" +
                "order by summary desc\n" +
                "limit 3";

        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DriverManager.getConnection(url, name, pass);
            ps = con.prepareStatement(sql);
            ps.setLong(1, id);
            ResultSet r = ps.executeQuery();
            List<GroupCodesOfClient> list = new LinkedList<>();
            while(r.next()){
                GroupCodesOfClient groupCodesOfClient = new GroupCodesOfClient();
                groupCodesOfClient.setClient_id(r.getLong("client_id"));
                groupCodesOfClient.setCountOfCode(r.getInt("count"));
                groupCodesOfClient.setGroupCode(r.getString("group_code"));
                groupCodesOfClient.setSummary((int) r.getDouble("summary"));
                list.add(groupCodesOfClient);
            }
            return list;
        } catch (SQLException throwable) {
            throwable.printStackTrace();
        }finally {
            try {
                if(con != null)
                    con.close();
                if(ps != null)
                    ps.close();
            } catch (SQLException throwables) {
                throwables.printStackTrace();
            }
        }
        return null;

    }


    public List<Amount> currentOrAverageAmount(Long id, String sql) {

        String currentByWeek = "select \n" +
                "\txxx.date \"date\"\n" +
                "    , coalesce(SUM(CAST(replace(sum, ',','.') as float8) ) *(-1), 0) summary\n" +
                "from pfm_transaction_data ptd\n" +
                "right join \n" +
                "(\n" +
                "\tselect to_char(to_date(CAST(generate_series('2021-08-20', '2021-09-30', '1 day'::interval) as text), 'YYYY-MM-DD'),'DD.MM.YYYY') \"date\"\n" +
                ") xxx on to_date(xxx.\"date\", 'DD.MM.YYYY')= to_date(ptd.date,'DD.MM.YYYY')\n" +
                "where to_char(to_date(xxx.\"date\",'DD.MM.YYYY'), 'IW') = '35'\n" +
                "and (CAST(replace(sum, ',','.') as float8) < 0 or CAST(replace(sum, ',','.') as float8) is NULL)\n" +
                "and (ptd.client_id = ? or ptd.client_id is NULL)\n" +
                "group by xxx.\"date\"" +
                "order by to_date(xxx.\"date\",'DD.MM.YYYY');";

        String averageByMonth = "select \n" +
                "\tto_char(to_date(ptd.\"date\",'DD.MM.YYYY'), 'Day') \"date\"\n" +
                "\t, AVG(CAST(replace(sum, ',','.') as float8))*(-1) summary\n" +
                "from pfm_transaction_data ptd\n" +
                "where ptd.client_id = ?\n" +
                "and to_char(to_date(ptd.date,'DD.MM.YYYY'), 'YYYY') = '2021'\n" +
                "and to_char(to_date(ptd.date,'DD.MM.YYYY'), 'MM') = '08'\n" +
                "and CAST(replace(sum, ',','.') as float8) < 0\n" +
                "group by to_char(to_date(ptd.\"date\",'DD.MM.YYYY'), 'Day');";
        if(sql.equals("averageByMonth"))
            sql = averageByMonth;
        if(sql.equals("currentByWeek"))
            sql = currentByWeek;

        List<Amount> currentAmount = null;
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = DriverManager.getConnection(url, name, pass);
            ps = con.prepareStatement(sql);
            ps.setLong(1, id);
            ResultSet r = ps.executeQuery();
            currentAmount = new LinkedList<>();
            while (r.next()){
                Amount amount = new Amount();
                amount.setData(r.getString("date"));
                amount.setSum((int)r.getDouble("summary"));
                currentAmount.add(amount);
            }
        } catch (SQLException throwable) {
            throwable.printStackTrace();
        }finally {
            try {
                if(con != null)
                    con.close();
                if(ps != null)
                    ps.close();
            } catch (SQLException throwables) {
                throwables.printStackTrace();
            }
        }
        return currentAmount;
    }


}