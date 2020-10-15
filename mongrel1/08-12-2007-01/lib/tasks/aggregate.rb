class Aggregator
  def initialize
    @db = ComputerGroup.connection
  end
  
  def aggregate_data_from(last_agg_time, interval=1.days)
    current_time = Time.now
    
    if last_agg_time.nil?
      start_time = current_time
    else
      start_time = last_agg_time + interval
    end
    
    return if current_time < start_time
    
    interval_count = (1 + (current_time - start_time) / interval).to_i
    
    interval_count.times do |i|
      ComputerGroup.insert_aggregate_data_at(start_time + interval * i)
    end
  end
  
  def purge_old_samples
    tables_to_purge = %w(agg_computer_groups_benchmarks
                         agg_computer_groups_vulns agg_computer_groups_dlp_rule_events)

    purge_intervals = [[7.days.ago, 1.days],
                       [60.days.ago, 7.days],
                       [730.days.ago, 30.days]]

    agg_records = get_all_agg_records_before(purge_intervals[0][0])
    deleted_agg_ids = get_agg_records_to_purge(agg_records, purge_intervals)
    
    return if deleted_agg_ids.empty?
    
    @db.transaction do
      purge_agg_table('agg_computer_groups', deleted_agg_ids, 'id')
    
      tables_to_purge.each do |table_name|
        purge_agg_table(table_name, deleted_agg_ids)
      end
    end
  end

  def get_all_agg_records_before(time)
    query = "SELECT id, time_stamp " \
            "FROM agg_computer_groups " \
            "WHERE time_stamp < #{@db.quote(time)} " \
            "ORDER BY time_stamp ASC"
    @db.select_all(query)
  end
  
  def purge_agg_table(table_name, deleted_agg_ids, key_name='agg_computer_group_id')
    @db.execute "DELETE FROM #{table_name} " \
                "WHERE #{key_name} " \
                "IN (#{deleted_agg_ids.map(&:to_s).join(',')})"
  end
  
  
  def get_agg_records_to_purge(agg_records, purge_intervals)
    return [] if agg_records.empty?
    
    returning purge_set = [] do
      purge_intervals.each do |purge_end_time, purge_interval|
        last_time = agg_records[0]['time_stamp']
        agg_records[1..-1].each do |r|
          break unless r['time_stamp'] < purge_end_time
        
          if r['time_stamp'] < last_time + purge_interval
            purge_set << r['id']
          else
            last_time = r['time_stamp']
          end
        end
      end
    end
  end
end

a = Aggregator.new
a.aggregate_data_from(ComputerGroup.most_recent_aggregation_time)
a.purge_old_samples()
